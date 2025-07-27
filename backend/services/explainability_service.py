# backend/services/explainability_service.py
"""
Explainability Service using SHAP

Provides model explanations for credit risk predictions.
"""

import joblib
import pandas as pd
import numpy as np
from pathlib import Path
import logging
from typing import Dict, Any, List
import shap

logger = logging.getLogger(__name__)

class ExplainabilityService:
    """Service for generating model explanations using SHAP"""
    
    def __init__(self, explainer_path: str = "trained_models/shap_explainer.pkl"):
        self.explainer_path = Path(explainer_path)
        self.explainer = None
        self._load_explainer()
    
    def _load_explainer(self):
        """Load the SHAP explainer"""
        try:
            if not self.explainer_path.exists():
                raise FileNotFoundError(f"SHAP explainer not found at {self.explainer_path}")
            
            self.explainer = joblib.load(self.explainer_path)
            logger.info(f"SHAP explainer loaded successfully from {self.explainer_path}")
            
        except Exception as e:
            logger.error(f"Error loading SHAP explainer: {str(e)}")
            raise
    
    def prepare_input_data(self, input_data: Dict[str, Any]) -> pd.DataFrame:
        """Prepare input data for SHAP explanation (same as prediction service)"""
        expected_features = [
            'person_income', 'person_emp_length', 'loan_amnt', 'loan_int_rate', 
            'loan_percent_income', 'cb_person_cred_hist_length', 'age', 
            'estimated_monthly_income', 'monthly_airtime_spend', 'monthly_data_usage_gb',
            'avg_calls_per_day', 'avg_sms_per_day', 'digital_wallet_usage',
            'monthly_digital_transactions', 'avg_transaction_amount', 
            'social_media_activity_score', 'mobile_banking_user',
            'digital_engagement_score', 'financial_inclusion_score',
            'electricity_bill_avg', 'water_bill_avg', 'gas_bill_avg',
            'total_utility_expense', 'utility_to_income_ratio', 
            'on_time_payments_12m', 'late_payments_12m', 'credit_risk_score'
        ]
        
        # Create DataFrame with expected features
        df = pd.DataFrame([input_data])
        
        # Ensure all expected features are present
        for feature in expected_features:
            if feature not in df.columns:
                df[feature] = 0
        
        # Select only expected features in correct order
        df = df[expected_features]
        df = df.fillna(0)
        
        return df
    
    def explain_prediction(self, input_data: Dict[str, Any], top_n: int = 10) -> Dict[str, Any]:
        """Generate SHAP explanation for a single prediction"""
        try:
            if self.explainer is None:
                raise ValueError("SHAP explainer not loaded")
            
            # Prepare input data
            df = self.prepare_input_data(input_data)
            
            # Calculate SHAP values
            shap_values = self.explainer.shap_values(df)
            
            # Handle different SHAP output formats
            if isinstance(shap_values, list):
                # For binary classification, take positive class SHAP values
                shap_values = shap_values[1]
            
            # Get feature names
            feature_names = df.columns.tolist()
            
            # Create explanation dictionary
            feature_contributions = {}
            for i, (feature, shap_value) in enumerate(zip(feature_names, shap_values[0])):
                feature_contributions[feature] = {
                    "shap_value": float(shap_value),
                    "feature_value": float(df.iloc[0, i]),
                    "impact": "increases_risk" if shap_value > 0 else "decreases_risk"
                }
            
            # Sort by absolute SHAP value and take top N
            sorted_features = sorted(
                feature_contributions.items(),
                key=lambda x: abs(x[1]["shap_value"]),
                reverse=True
            )[:top_n]
            
            # Format explanation
            explanation = {
                "top_features": dict(sorted_features),
                "base_value": float(self.explainer.expected_value[1] if isinstance(self.explainer.expected_value, list) else self.explainer.expected_value),
                "prediction_value": float(self.explainer.expected_value[1] if isinstance(self.explainer.expected_value, list) else self.explainer.expected_value) + float(np.sum(shap_values[0])),
                "total_shap_contribution": float(np.sum(shap_values[0]))
            }
            
            # Add human-readable explanations
            explanation["readable_explanation"] = self._create_readable_explanation(
                dict(sorted_features)
            )
            
            logger.info("SHAP explanation generated successfully")
            return explanation
            
        except Exception as e:
            logger.error(f"Error generating SHAP explanation: {str(e)}")
            raise
    
    def _create_readable_explanation(self, top_features: Dict[str, Dict[str, Any]]) -> List[str]:
        """Create human-readable explanations"""
        explanations = []
        
        # Feature name mappings for better readability
        feature_mappings = {
            'person_income': 'Annual Income',
            'loan_amnt': 'Loan Amount',
            'loan_int_rate': 'Interest Rate',
            'loan_percent_income': 'Loan-to-Income Ratio',
            'cb_person_cred_hist_length': 'Credit History Length',
            'age': 'Age',
            'utility_to_income_ratio': 'Utility-to-Income Ratio',
            'on_time_payments_12m': 'On-time Payments (12m)',
            'late_payments_12m': 'Late Payments (12m)',
            'digital_engagement_score': 'Digital Engagement Score',
            'credit_risk_score': 'Credit Risk Score',
            'monthly_digital_transactions': 'Monthly Digital Transactions',
            'social_media_activity_score': 'Social Media Activity',
            'mobile_banking_user': 'Mobile Banking Usage'
        }
        
        for feature, data in top_features.items():
            readable_name = feature_mappings.get(feature, feature.replace('_', ' ').title())
            shap_value = data['shap_value']
            feature_value = data['feature_value']
            impact = data['impact']
            
            impact_text = "increases" if impact == "increases_risk" else "decreases"
            
            explanation = f"{readable_name} (value: {feature_value:.2f}) {impact_text} risk by {abs(shap_value):.3f}"
            explanations.append(explanation)
        
        return explanations
    
    def get_global_feature_importance(self) -> Dict[str, float]:
        """Get global feature importance (if available from explainer)"""
        # This would require storing feature importance during explainer creation
        # For now, return empty dict - could be enhanced with stored importance values
        logger.warning("Global feature importance not available from SHAP explainer")
        return {}
    
    def explain_batch(self, input_data_list: List[Dict[str, Any]], top_n: int = 10) -> List[Dict[str, Any]]:
        """Generate explanations for multiple predictions"""
        explanations = []
        
        for input_data in input_data_list:
            try:
                explanation = self.explain_prediction(input_data, top_n)
                explanations.append(explanation)
            except Exception as e:
                logger.error(f"Error in batch explanation: {str(e)}")
                explanations.append({
                    "error": str(e),
                    "top_features": {},
                    "readable_explanation": ["Error generating explanation"]
                })
        
        return explanations
