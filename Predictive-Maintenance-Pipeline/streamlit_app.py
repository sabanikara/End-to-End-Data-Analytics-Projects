"""Persian Streamlit client for the existing pipe_fastapi_starter API.

Run this file with Streamlit, in the separate pipe-ui environment.
Keep the existing FastAPI service running on 127.0.0.1:8000.

Only HTTP requests are sent to the API. No model is loaded/retrained here;
no prediction or maintenance recommendation is fabricated. SQL writes are
performed only by the updated FastAPI service after a prediction submission.
The form options and sample values come from the existing /model-info route.
"""
from __future__ import annotations

# SQL_LOGGING_UPDATE_V1

import math
from datetime import datetime, timezone
from typing import Any, Literal

import requests

API_BASE = "http://127.0.0.1:8000"
FEATURES = [
    "Pipe_Size_mm", "Thickness_mm", "Material", "Grade", "Max_Pressure_psi",
    "Temperature_C", "Corrosion_Impact_Percent", "Material_Loss_Percent", "Time_Years",
]
CLASSES = ("Critical", "Moderate", "Normal")
CLASS_FA = {"Critical": "بحرانی", "Moderate": "متوسط", "Normal": "عادی"}


class ApiProblem(RuntimeError):
    """An actionable error to show without inventing a successful result."""

    def __init__(self, message: str, details: Any = None) -> None:
        super().__init__(message)
        self.details = details


def api_json(
    method: Literal["GET", "POST"],
    path: Literal["/health", "/model-info", "/predict"],
    payload: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Call the fixed loopback API with bounded waits and no POST retries."""
    try:
        with requests.Session() as session:
            # This client is loopback-only: do not send localhost via a VPN proxy.
            # Change this policy deliberately before adapting for a remote API.
            session.trust_env = False
            response = session.request(
                method, API_BASE + path, json=payload,
                timeout=(3, 30 if method == "POST" else 5),
                allow_redirects=False,
                headers={"Accept": "application/json"},
            )
    except requests.Timeout as exc:
        raise ApiProblem(
            "پاسخ API به‌موقع نرسید. پیش از ارسال دوباره، آخرین ثبت را در SQL Server بررسی کن؛ "
            "ممکن است ثبت انجام شده باشد و تکرار درخواست یک رکورد دیگر بسازد."
        ) from exc
    except requests.ConnectionError as exc:
        raise ApiProblem(
            "اتصال به FastAPI برقرار نشد. پنجرهٔ اولِ CMD و سرویس روی پورت 8000 باید باز باشند."
        ) from exc
    except requests.RequestException as exc:
        raise ApiProblem("ارسال درخواست به API ناموفق بود.", str(exc)) from exc

    try:
        data = response.json()
    except ValueError as exc:
        raise ApiProblem(
            "پاسخ سرویس JSON معتبر نیست؛ بررسی کن پورت 8000 مربوط به همین پروژه باشد.",
            {"http_status": response.status_code},
        ) from exc

    if response.status_code != 200:
        messages = {
            422: "بعضی ورودی‌ها توسط API پذیرفته نشدند. جزئیات خطا را بررسی کن.",
            503: "درخواست کامل نشد؛ مدل آماده نیست یا ثبت در دیتابیس تأیید نشد. جزئیات خطا و پنجرهٔ FastAPI را بررسی کن.",
            500: "API هنگام پیش‌بینی خطا داد. خروجی پنجرهٔ FastAPI را بررسی کن.",
            404: "مسیر موردنیاز پیدا نشد؛ باید همان FastAPI پروژه روی پورت 8000 اجرا باشد.",
        }
        raise ApiProblem(
            messages.get(response.status_code, f"خطای ارتباط با API: HTTP {response.status_code}"),
            data,
        )
    if not isinstance(data, dict):
        raise ApiProblem("ساختار پاسخ API با این رابط سازگار نیست.")
    return data


def validate_info(info: dict[str, Any]) -> None:
    """Reject an unrelated service instead of quietly using invented defaults."""
    if info.get("features") != FEATURES or set(info.get("classes", [])) != set(CLASSES):
        raise ApiProblem("ورودی‌ها یا کلاس‌های این API با نسخهٔ رابط کاربری سازگار نیستند.")
    categories = info.get("categories")
    example = info.get("example_input")
    if not isinstance(categories, dict) or not isinstance(example, dict):
        raise ApiProblem("گزینه‌ها یا ورودی نمونه در پاسخ /model-info وجود ندارند.")
    if set(example) != set(FEATURES):
        raise ApiProblem("ورودی نمونهٔ API باید هر ۹ فیلد موردنیاز را داشته باشد.")
    for name in ("Material", "Grade"):
        options = categories.get(name)
        if (not isinstance(options, list) or not options
                or any(not isinstance(item, str) or not item for item in options)
                or example[name] not in options):
            raise ApiProblem(f"فهرست {name} یا مقدار نمونهٔ آن در API معتبر نیست.")
    for name in FEATURES:
        if name not in ("Material", "Grade"):
            value = example[name]
            if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
                raise ApiProblem(f"مقدار نمونهٔ {name} عدد معتبر نیست.")
    if any(example[name] <= 0 for name in ("Pipe_Size_mm", "Thickness_mm", "Max_Pressure_psi")):
        raise ApiProblem("مقادیر نمونهٔ اندازه، ضخامت و فشار باید مثبت باشند.")
    if not 0 <= example["Corrosion_Impact_Percent"] <= 100:
        raise ApiProblem("درصد اثر خوردگی در نمونهٔ API خارج از دامنهٔ عددی است.")
    if example["Material_Loss_Percent"] < 0 or example["Time_Years"] < 0:
        raise ApiProblem("درصد افت و مدت‌زمانِ نمونه نباید منفی باشند.")
    for name in ("Pipe_Size_mm", "Time_Years"):
        if int(example[name]) != example[name]:
            raise ApiProblem(f"مقدار نمونهٔ {name} باید عدد صحیح باشد.")


def validate_prediction(result: dict[str, Any]) -> None:
    """Check the response contract; scores are not failure probabilities."""
    prediction = result.get("predicted_condition")
    probabilities = result.get("class_probabilities")
    if prediction not in CLASSES or not isinstance(probabilities, dict):
        raise ApiProblem("ساختار نتیجهٔ پیش‌بینی معتبر نیست.")
    if set(probabilities) != set(CLASSES):
        raise ApiProblem("پاسخ باید امتیاز هر سه کلاس مدل را داشته باشد.")
    for value in probabilities.values():
        if (isinstance(value, bool) or not isinstance(value, (int, float))
                or not math.isfinite(value) or not 0 <= value <= 1):
            raise ApiProblem("یکی از امتیازهای مدل نامعتبر است.")
    if not math.isclose(sum(probabilities.values()), 1.0, abs_tol=1e-6):
        raise ApiProblem("جمع امتیازهای کلاس‌ها برابر یک نیست؛ نتیجه نمایش داده نشد.")
    if not isinstance(result.get("model_id"), str) or not result["model_id"]:
        raise ApiProblem("شناسهٔ مدل در پاسخ وجود ندارد.")
    if result.get("data_quality_status") not in ("not_fully_checked", "review_required"):
        raise ApiProblem("وضعیت کنترل کیفیت در پاسخ مشخص نیست.")
    warnings = result.get("warnings")
    if not isinstance(warnings, list) or any(not isinstance(item, str) for item in warnings):
        raise ApiProblem("فهرست هشدارهای API معتبر نیست.")
    if not isinstance(result.get("interpretation"), str):
        raise ApiProblem("توضیح دامنهٔ تفسیر در پاسخ API وجود ندارد.")
    if result.get("database_saved") is True:
        log_id = result.get("prediction_id")
        if isinstance(log_id, bool) or not isinstance(log_id, int) or log_id <= 0:
            raise ApiProblem("شناسهٔ ثبت دیتابیس در پاسخ معتبر نیست.")
        if not isinstance(result.get("saved_at_utc"), str) or not result["saved_at_utc"]:
            raise ApiProblem("زمان ثبت دیتابیس در پاسخ وجود ندارد.")


def show_error(st: Any, exc: ApiProblem) -> None:
    st.error(str(exc))
    if exc.details is not None:
        with st.expander("جزئیات خطا برای عیب‌یابی"):
            st.json(exc.details)


def main() -> None:
    import streamlit as st

    st.set_page_config(page_title="طبقه‌بندی وضعیت لوله", layout="wide")
    # Static CSS only; no external fonts or remote assets are required by this file.
    st.markdown("""
    <style>
    [data-testid="stMarkdownContainer"] p,
    [data-testid="stMarkdownContainer"] h1,
    [data-testid="stMarkdownContainer"] h2,
    [data-testid="stMarkdownContainer"] h3,
    [data-testid="stWidgetLabel"], [data-testid="stMetricLabel"] {
        direction: rtl; text-align: right;
    }
    input { direction: ltr; text-align: left; }
    pre, code { direction: ltr; text-align: left; }
    </style>
    """, unsafe_allow_html=True)
    st.title("طبقه‌بندی وضعیت لوله")
    st.caption("فرم Streamlit ← درخواست به FastAPI ← خروجی مدل آموزش‌دیده")
    st.warning(
        "نسخهٔ آموزشی: طبقه‌بندی وضعیت بر اساس اطلاعات واردشده؛ "
        "نه پیش‌بینی تأییدشدهٔ خرابی آینده یا دستور تعمیر. "
        "سازگاری جنس و گرید و ایمنی مهندسی تأیید نشده‌اند."
    )

    st.button("بررسی دوبارهٔ اتصال")  # A click reruns the health check below.
    try:
        health = api_json("GET", "/health")
        if health.get("status") != "ok" or health.get("model_loaded") is not True:
            raise ApiProblem("سرویس هنوز آمادهٔ پیش‌بینی نیست.", health)
        info = api_json("GET", "/model-info")
        validate_info(info)
    except ApiProblem as exc:
        show_error(st, exc)
        st.info("در پنجرهٔ اولِ CMD و داخل پوشهٔ پروژه، FastAPI را روشن نگه دار:")
        st.code(
            r".venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000",
            language="bat",
        )
        st.stop()

    st.success("اتصال به API برقرار است؛ مدل آمادهٔ دریافت ورودی است.")
    example = info["example_input"]
    categories = info["categories"]
    st.subheader("اطلاعات ورودی")
    st.caption(
        "مقادیر اولیه از نمونهٔ خود API گرفته شده‌اند. برای اولین آزمایش، آن‌ها را تغییر نده. "
        "درصدها را در مقیاس صفر تا صد وارد کن: مثلاً 31.72 یعنی 31.72٪."
    )
    with st.form("pipe_input", clear_on_submit=False, enter_to_submit=False):
        c1, c2, c3 = st.columns(3)
        with c1:
            material = st.selectbox(
                "جنس لوله — Material", categories["Material"],
                index=categories["Material"].index(example["Material"]), key="material",
            )
            grade = st.selectbox(
                "گرید — Grade", categories["Grade"],
                index=categories["Grade"].index(example["Grade"]), key="grade",
                help="گزینه‌های ثبت‌شده در مدل؛ این فهرست تأییدکنندهٔ سازگاری جنس و گرید نیست.",
            )
            size = st.number_input(
                "اندازهٔ لوله (mm)", min_value=1,
                value=int(example["Pipe_Size_mm"]), step=1, key="pipe_size",
            )
        with c2:
            thickness = st.number_input(
                "ضخامت مرجعِ فرض‌شده (mm)", min_value=0.01,
                value=float(example["Thickness_mm"]), step=0.01, format="%.2f", key="thickness",
            )
            pressure = st.number_input(
                "فشار حداکثر ثبت‌شده (psi)", min_value=0.01,
                value=float(example["Max_Pressure_psi"]), step=1.0, format="%.2f", key="pressure",
                help="این فیلد را بدون مستندات منبع، فشار عملیاتیِ اندازه‌گیری‌شده تلقی نکن.",
            )
            temperature = st.number_input(
                "دما (°C)", value=float(example["Temperature_C"]),
                step=0.1, format="%.2f", key="temperature",
            )
        with c3:
            corrosion = st.number_input(
                "اثر خوردگی (%)", min_value=0.0, max_value=100.0,
                value=float(example["Corrosion_Impact_Percent"]),
                step=0.01, format="%.2f", key="corrosion",
            )
            loss = st.number_input(
                "افت ثبت‌شده (%) — Material Loss", min_value=0.0,
                value=float(example["Material_Loss_Percent"]),
                step=0.01, format="%.2f", key="loss",
                help="مقادیر بالاتر از 100 بدون تغییر به API می‌روند و نیازمند بررسی علامت می‌خورند.",
            )
            years = st.number_input(
                "مدت‌زمان ثبت‌شده (سال)", min_value=0,
                value=int(example["Time_Years"]), step=1, key="years",
                help="مدت‌زمان عددیِ ثبت‌شده در داده؛ تاریخ بازرسی نیست.",
            )
        submitted = st.form_submit_button("پیش‌بینی وضعیت", type="primary")

    if submitted:
        # Never show an earlier success as the answer to a failed new request.
        st.session_state.pop("last_prediction", None)
        payload = {
            "Pipe_Size_mm": int(size), "Thickness_mm": float(thickness),
            "Material": material, "Grade": grade, "Max_Pressure_psi": float(pressure),
            "Temperature_C": float(temperature), "Corrosion_Impact_Percent": float(corrosion),
            "Material_Loss_Percent": float(loss), "Time_Years": int(years),
        }
        try:
            with st.spinner("در حال دریافت پاسخ از مدل..."):
                result = api_json("POST", "/predict", payload)
                validate_prediction(result)
            st.session_state["last_prediction"] = {
                "submitted_at_utc": datetime.now(timezone.utc).isoformat(),
                "input": payload, "response": result,
            }
        except ApiProblem as exc:
            show_error(st, exc)

    record = st.session_state.get("last_prediction")
    if record:
        result = record["response"]
        prediction = result["predicted_condition"]
        scores = result["class_probabilities"]
        st.divider()
        st.subheader("نتیجهٔ آخرین درخواست موفق")
        st.caption("این نتیجه مربوط به آخرین ورودی ارسال‌شده است؛ پس از تغییر فرم دوباره دکمه را بزن.")
        a, b = st.columns(2)
        a.metric("وضعیت طبقه‌بندی‌شده", f"{CLASS_FA[prediction]} ({prediction})")
        b.metric("امتیاز کلاس انتخاب‌شده", f"{scores[prediction] * 100:.2f}%")
        st.caption("امتیاز کلاس، دقت کل مدل یا احتمال معتبر خرابی واقعی نیست.")
        st.table([
            {"کلاس": f"{CLASS_FA[label]} ({label})", "امتیاز مدل": f"{scores[label] * 100:.2f}%"}
            for label in sorted(CLASSES, key=lambda item: scores[item], reverse=True)
        ])
        if result["data_quality_status"] == "review_required":
            st.warning(
                "نیازمند بررسی داده: درصد افت از 100 بیشتر است. با فرض ضخامت مرجع، "
                "اطلاعات اندازه‌گیری باید بررسی شود. مقدار ورودی محدود یا اصلاح نشده است."
            )
        else:
            st.caption("کنترل کیفیت کامل و تأیید مهندسی انجام نشده است؛ این نتیجه برچسب Pass نیست.")
        st.caption("شناسهٔ مدل: " + result["model_id"])
        with st.expander("ورودی ارسال‌شده، هشدارها و پاسخ کامل API"):
            st.json(record)
        if result.get("database_saved") is True:
            st.success(f"نتیجه در SQL Server ذخیره شد. شناسهٔ ثبت: {result['prediction_id']}")
            st.caption("زمان ثبت بر مبنای UTC: " + result["saved_at_utc"])
            st.caption("این شناسه مربوط به درخواست پیش‌بینی است، نه شناسهٔ یک لوله یا بازرسی واقعی.")
        else:
            st.warning(
                "ثبت دیتابیس برای این پاسخ تأیید نشده است. پس از راه‌اندازی نسخهٔ جدید FastAPI، "
                "یک درخواست تازه ارسال کن. پاسخ قبلی به‌صورت خودکار ذخیره نمی‌شود."
            )
    else:
        st.info("برای اولین آزمایش، با همین مقادیر نمونه روی «پیش‌بینی وضعیت» کلیک کن.")


if __name__ == "__main__":
    main()
