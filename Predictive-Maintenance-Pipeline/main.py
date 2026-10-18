"""Local educational API for the user's ORIGINAL, already-fitted pipeline.

Run: python -m uvicorn main:app --host 127.0.0.1 --port 8000
This service never trains a replacement model or substitutes rule-based predictions.
Do not expose this demonstration publicly without authentication and hardening.
"""
from __future__ import annotations

import hashlib
import json
import logging
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Annotated, Literal

import joblib
import numpy as np
import pandas as pd
import sklearn
from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import BaseModel, ConfigDict, Field, field_validator
from sklearn.pipeline import Pipeline

# SQL_LOGGING_UPDATE_V1
from database_logger import PredictionStoreError, save_prediction

ROOT = Path(__file__).resolve().parent
MODEL_PATH = ROOT / "models" / "predictive_maintenance_model.joblib"
METADATA = json.loads((ROOT / "model_metadata.json").read_text(encoding="utf-8"))
EXAMPLE = json.loads((ROOT / "example_input.json").read_text(encoding="utf-8"))
FEATURES = METADATA["features"]
EXPECTED_SKLEARN = METADATA["sklearn_version_from_serialized_state"]
logger = logging.getLogger("pipe_api")

MaterialName = Literal["Carbon Steel", "Fiberglass", "HDPE", "PVC", "Stainless Steel"]
GradeName = Literal[
    "API 5L X42", "API 5L X52", "API 5L X65", "ASTM A106 Grade B", "ASTM A333 Grade 6"
]
ConditionName = Literal["Critical", "Moderate", "Normal"]
PositiveNumber = Annotated[float, Field(gt=0, allow_inf_nan=False)]
NonNegativeNumber = Annotated[float, Field(ge=0, allow_inf_nan=False)]
Probability = Annotated[float, Field(ge=0, le=1, allow_inf_nan=False)]


class PipeInput(BaseModel):
    """The nine RAW feature names expected by the fitted pipeline.

    These limits validate data types/basic numerical consistency only.
    They are NOT certified engineering operating limits.
    """
    model_config = ConfigDict(
        extra="forbid", str_strip_whitespace=True, allow_inf_nan=False,
        json_schema_extra={"examples": [EXAMPLE]},
    )
    Pipe_Size_mm: Annotated[int, Field(gt=0)]
    Thickness_mm: PositiveNumber
    Material: MaterialName
    Grade: GradeName
    Max_Pressure_psi: PositiveNumber
    Temperature_C: Annotated[float, Field(allow_inf_nan=False)]
    Corrosion_Impact_Percent: Annotated[float, Field(ge=0, le=100, allow_inf_nan=False)]
    # Keep the original 0..100 scale (31.72 means 31.72%). Do not divide by 100.
    # >100 is flagged, not silently clipped: such values existed in the input data.
    Material_Loss_Percent: NonNegativeNumber
    Time_Years: Annotated[int, Field(ge=0)]

    @field_validator("*", mode="before")
    @classmethod
    def reject_boolean_values(cls, value):
        # bool is otherwise accepted as a number by many Python conversion paths.
        if isinstance(value, bool):
            raise ValueError("Use a numeric value or category, not true/false.")
        return value


class PredictionResponse(BaseModel):
    predicted_condition: ConditionName
    class_probabilities: dict[str, Probability]
    model_id: str
    data_quality_status: Literal["not_fully_checked", "review_required"]
    warnings: list[str]
    interpretation: str
    # Storage receipt: populated only after the SQL transaction commits.
    prediction_id: Annotated[int, Field(gt=0)] | None = None
    saved_at_utc: str | None = None
    database_saved: bool = False


class PredictionEngine:
    """Load a fixed, verified artifact once; accept RAW features for inference."""
    def __init__(self, model_path: Path):
        if sklearn.__version__ != EXPECTED_SKLEARN:
            raise RuntimeError(
                f"This artifact requires scikit-learn=={EXPECTED_SKLEARN}; "
                f"installed version is {sklearn.__version__}. "
                "Install requirements.txt in a new virtual environment."
            )
        if not model_path.is_file():
            raise RuntimeError("The model is missing from the models folder.")
        digest = hashlib.sha256(model_path.read_bytes()).hexdigest()
        if digest != METADATA["sha256"]:
            raise RuntimeError(
                "Model checksum does not match this project's original artifact. "
                "Do not replace it with a downloaded error page or an untrusted model."
            )
        # joblib can execute code. Load only this explicitly trusted local artifact;
        # the API intentionally provides NO model-file upload endpoint.
        pipeline = joblib.load(model_path)
        if not isinstance(pipeline, Pipeline):
            raise RuntimeError("Expected a complete sklearn Pipeline, not a bare classifier.")
        if list(pipeline.feature_names_in_) != FEATURES:
            raise RuntimeError("Raw input schema does not match the inspected model.")
        if list(map(str, pipeline.classes_)) != METADATA["classes"]:
            raise RuntimeError("The class labels do not match the inspected artifact.")
        # Confirm inference at startup, not just successful deserialization.
        sample = pd.DataFrame([EXAMPLE], columns=FEATURES)
        sample_prob = np.asarray(pipeline.predict_proba(sample), dtype=float)
        if sample_prob.shape != (1, 3) or not np.isfinite(sample_prob).all():
            raise RuntimeError("Model startup inference produced invalid probabilities.")
        if not np.isclose(sample_prob.sum(), 1.0):
            raise RuntimeError("Model startup probabilities do not sum to one.")
        if str(pipeline.predict(sample)[0]) not in METADATA["classes"]:
            raise RuntimeError("Model startup inference returned an unexpected class.")
        self.pipeline = pipeline
        self.model_id = "rf-200-" + digest[:12]

    def predict(self, payload: PipeInput) -> PredictionResponse:
        frame = pd.DataFrame([payload.model_dump()], columns=FEATURES)
        prediction = str(self.pipeline.predict(frame)[0])
        probabilities = np.asarray(self.pipeline.predict_proba(frame)[0], dtype=float)
        if not np.isfinite(probabilities).all() or not np.isclose(probabilities.sum(), 1.0):
            raise RuntimeError("The model returned invalid probabilities.")
        messages = [
            "Material_Loss_Percent remains an input; this is not a leakage-free forecast of future failure.",
            "Material/grade compatibility and engineering safety have not been validated.",
        ]
        status = "not_fully_checked"
        if payload.Material_Loss_Percent > 100:
            status = "review_required"
            messages.append(
                "Material_Loss_Percent exceeds 100. Under the baseline-thickness assumption, "
                "verify the source measurement before interpreting this classification. The value was not clipped."
            )
        return PredictionResponse(
            predicted_condition=prediction,
            class_probabilities={
                str(label): float(prob)
                for label, prob in zip(self.pipeline.classes_, probabilities, strict=True)
            },
            model_id=self.model_id,
            data_quality_status=status,
            warnings=messages,
            interpretation=(
                "Educational classification of the supplied current-condition data. "
                "Class probabilities are not validated failure probabilities. "
                "This response is not a repair instruction or an engineering safety approval."
            ),
        )


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.engine = None
    app.state.load_error = None
    try:
        app.state.engine = PredictionEngine(MODEL_PATH)
        logger.info("Original pipeline loaded; startup inference check passed.")
    except Exception as exc:
        # Keep /docs available for troubleshooting; /health and /predict return 503.
        # Never return a fake prediction when loading fails.
        logger.exception("Model could not be initialized")
        app.state.load_error = (
            str(exc) if isinstance(exc, RuntimeError) else
            f"Model initialization failed ({type(exc).__name__}). Check the terminal and requirements.txt."
        )
    yield
    app.state.engine = None


app = FastAPI(
    title="Pipe Condition Classification API",
    version="0.2.0",
    description=(
        "Local educational deployment of the user's original 200-tree Random Forest pipeline. "
        "This is current-condition classification, not a validated forecast of future failures. "
        "Successful POST /predict requests are saved to SQL Server before returning a response. "
        "The Streamlit client communicates with this API; it does not access the model or database directly."
    ),
    lifespan=lifespan,
)


@app.exception_handler(RequestValidationError)
async def validation_error_handler(request: Request, exc: RequestValidationError):
    # Exclude raw input / exception contexts: NaN or Infinity in malformed requests
    # must not crash JSON error serialization, and submitted data should not be echoed.
    return JSONResponse(
        status_code=422,
        content={"detail": [
            {"loc": list(error["loc"]), "msg": error["msg"], "type": error["type"]}
            for error in exc.errors()
        ]},
    )


@app.get("/", tags=["Service"])
def home():
    return {"project": "Pipe Condition Classification", "docs": "/docs", "health": "/health"}


@app.get("/health", tags=["Service"])
def health(request: Request):
    engine = getattr(request.app.state, "engine", None)
    if engine is None:
        raise HTTPException(
            status_code=503,
            detail={
                "status": "not_ready", "model_loaded": False,
                "message": getattr(request.app.state, "load_error", "Application startup has not completed."),
            },
        )
    return {
        "status": "ok", "model_loaded": True,
        "model_id": engine.model_id, "sklearn_version": sklearn.__version__,
        # This reports configuration, not a successful database connection/write.
        "database_logging": "enabled",
    }


@app.get("/model-info", tags=["Service"])
def model_info():
    return {
        "features": FEATURES, "classes": METADATA["classes"],
        "categories": METADATA["categories"], "n_estimators": METADATA["n_estimators"],
        "expected_sklearn_version": EXPECTED_SKLEARN,
        "accuracy_reported_by_user": 0.875,
        "accuracy_note": "User-reported notebook result; not an independent test of this API.",
        "example_input": EXAMPLE,
        "scope": "Educational current-condition classification; successful predictions are logged to SQL Server.",
    }


@app.post("/predict", response_model=PredictionResponse, tags=["Prediction"])
def predict(payload: PipeInput, request: Request):
    engine = getattr(request.app.state, "engine", None)
    if engine is None:
        raise HTTPException(status_code=503, detail="Model is not ready. See /health and the server terminal.")
    try:
        prediction = engine.predict(payload)
    except Exception:
        logger.exception("Prediction failed")
        raise HTTPException(status_code=500, detail="Prediction failed. See the server terminal.") from None
    try:
        # This synchronous endpoint is run in FastAPI's worker thread pool.
        # Database writes are not background tasks: require commit before 200.
        return save_prediction(
            payload.model_dump(mode="json"), prediction.model_dump(mode="json")
        )
    except PredictionStoreError:
        raise HTTPException(
            status_code=503,
            detail={
                "code": "PREDICTION_STORAGE_UNCONFIRMED",
                "message": (
                    "Prediction ran, but SQL Server storage was not confirmed. "
                    "Check the server terminal and dbo.PredictionLogs before resubmitting; "
                    "a lost commit acknowledgement can otherwise cause duplicate entries."
                ),
            },
        ) from None
