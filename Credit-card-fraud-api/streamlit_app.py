import pandas as pd
import requests
import streamlit as st


# ============================================================
# APPLICATION CONFIGURATION
# ============================================================

API_URL = "http://127.0.0.1:8000"

st.set_page_config(
    page_title="Credit Card Fraud Detection",
    page_icon="💳",
    layout="wide"
)

st.title("💳 Credit Card Fraud Detection")

st.caption(
    "Machine Learning based transaction classification"
)

st.divider()


# ============================================================
# API HEALTH CHECK
# ============================================================

st.sidebar.title("System Status")

try:

    health_response = requests.get(
        f"{API_URL}/health",
        timeout=3
    )

    if health_response.status_code == 200:
        st.sidebar.success("API Connected")

    else:
        st.sidebar.error("API Unavailable")

except requests.exceptions.RequestException:

    st.sidebar.error("API Disconnected")


# ============================================================
# TRANSACTION INPUT FORM
# ============================================================

st.subheader("Transaction Information")

st.info(
    "Enter the transaction features. "
    "All 30 model inputs are required."
)


with st.form("fraud_detection_form"):

    col1, col2 = st.columns(2)

    # --------------------------------------------------------
    # Time
    # --------------------------------------------------------

    with col1:

        time_value = st.number_input(
            "Time (seconds)",
            min_value=0.0,
            value=0.0,
            step=1.0
        )

    # --------------------------------------------------------
    # Amount
    # --------------------------------------------------------

    with col2:

        amount_value = st.number_input(
            "Transaction Amount",
            min_value=0.0,
            value=0.0,
            step=1.0
        )


    st.divider()


    # --------------------------------------------------------
    # PCA Features
    # --------------------------------------------------------

    st.subheader("PCA Features")

    st.caption(
        "Enter the transformed feature values V1 to V28."
    )


    features = {}

    feature_columns = st.columns(3)


    for i in range(1, 29):

        with feature_columns[(i - 1) % 3]:

            features[f"V{i}"] = st.number_input(
                f"V{i}",
                value=0.0,
                step=0.1,
                format="%.8f",
                key=f"feature_v{i}"
            )


    st.divider()


    submitted = st.form_submit_button(
        "Analyze Transaction",
        type="primary",
        use_container_width=True
    )


# ============================================================
# SEND PREDICTION REQUEST TO FASTAPI
# ============================================================

if submitted:

    payload = {
        "Time": time_value,
        **features,
        "Amount": amount_value
    }


    try:

        response = requests.post(
            f"{API_URL}/predict",
            json=payload,
            timeout=15
        )


        # ----------------------------------------------------
        # Successful prediction
        # ----------------------------------------------------

        if response.status_code == 200:

            result = response.json()

            st.divider()

            st.subheader("Prediction Result")


            prediction = result["prediction"]


            if prediction == 1:

                st.error(
                    "🚨 Fraudulent Transaction"
                )

            else:

                st.success(
                    "✅ Normal Transaction"
                )


            # ------------------------------------------------
            # Prediction metrics
            # ------------------------------------------------

            col1, col2, col3 = st.columns(3)


            col1.metric(
                "Prediction",
                result["prediction_label"]
            )


            col2.metric(
                "Fraud Score",
                f'{result["fraud_score"]:.6f}'
            )


            col3.metric(
                "Processing Time",
                f'{result["processing_time_ms"]:.2f} ms'
            )


            st.caption(
                f'Threshold: '
                f'{result["threshold"]:.12f}'
            )


            st.caption(
                f'Request ID: '
                f'{result["request_id"]}'
            )


            st.info(
                "Fraud Score is a model output, "
                "not a calibrated probability of fraud."
            )


        # ----------------------------------------------------
        # Input validation error
        # ----------------------------------------------------

        elif response.status_code == 422:

            st.error(
                "Input validation failed"
            )

            st.json(
                response.json()
            )


        # ----------------------------------------------------
        # Other API error
        # ----------------------------------------------------

        else:

            st.error(
                f"API Error: "
                f"{response.status_code}"
            )

            st.code(
                response.text
            )


    # --------------------------------------------------------
    # FastAPI connection error
    # --------------------------------------------------------

    except requests.exceptions.ConnectionError:

        st.error(
            "Cannot connect to FastAPI. "
            "Make sure the API server is running."
        )


    # --------------------------------------------------------
    # Request timeout
    # --------------------------------------------------------

    except requests.exceptions.Timeout:

        st.error(
            "API request timed out."
        )


    # --------------------------------------------------------
    # Other request error
    # --------------------------------------------------------

    except requests.exceptions.RequestException as error:

        st.error(
            f"Request error: {error}"
        )


# ============================================================
# PROJECT DISCLAIMER
# ============================================================

st.divider()

st.caption(
    "Educational and portfolio project. "
    "Predictions are not intended "
    "for real banking decisions."
)


# ============================================================
# PREDICTION HISTORY
# ============================================================

st.divider()

st.header("Prediction History")

st.caption(
    "Recent predictions stored in SQL Server."
)


if st.button(
    "Load / Refresh History",
    use_container_width=False
):

    try:

        history_response = requests.get(
            f"{API_URL}/predictions",
            params={
                "limit": 100
            },
            timeout=10
        )


        # ----------------------------------------------------
        # History loaded successfully
        # ----------------------------------------------------

        if history_response.status_code == 200:

            history_data = (
                history_response.json()
            )

            records = (
                history_data["items"]
            )


            # ------------------------------------------------
            # Count predictions
            # ------------------------------------------------

            fraud_count = sum(
                row["Prediction"] == 1
                for row in records
            )


            normal_count = sum(
                row["Prediction"] == 0
                for row in records
            )


            total_count = len(records)


            # ------------------------------------------------
            # Summary metrics
            # ------------------------------------------------

            col1, col2, col3 = st.columns(3)


            col1.metric(
                "Total Predictions",
                total_count
            )


            col2.metric(
                "Fraud",
                fraud_count
            )


            col3.metric(
                "Normal",
                normal_count
            )


            # ------------------------------------------------
            # Fraud vs Normal chart
            # ------------------------------------------------

            st.subheader(
                "Prediction Distribution"
            )


            chart_data = pd.DataFrame(
                {
                    "Prediction Type": [
                        "Normal",
                        "Fraud"
                    ],
                    "Count": [
                        normal_count,
                        fraud_count
                    ]
                }
            )


            st.bar_chart(
                chart_data,
                x="Prediction Type",
                y="Count"
            )


            # ------------------------------------------------
            # Prediction history table
            # ------------------------------------------------

            st.subheader(
                "Recent Transactions"
            )


            if records:

                history_df = pd.DataFrame(
                    records
                )


                st.dataframe(
                    history_df,
                    use_container_width=True,
                    hide_index=True
                )


            else:

                st.info(
                    "No prediction records found."
                )


        # ----------------------------------------------------
        # FastAPI returned an error
        # ----------------------------------------------------

        else:

            st.error(
                f"API Error: "
                f"{history_response.status_code}"
            )


    # --------------------------------------------------------
    # Could not reach FastAPI
    # --------------------------------------------------------

    except requests.exceptions.ConnectionError:

        st.error(
            "Cannot connect to FastAPI."
        )


    except requests.exceptions.Timeout:

        st.error(
            "History request timed out."
        )


    except requests.exceptions.RequestException as error:

        st.error(
            f"Could not load history: {error}"
        )