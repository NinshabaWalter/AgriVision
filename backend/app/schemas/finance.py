from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class LoanTypeEnum(str, Enum):
    CROP_PRODUCTION = "crop_production"
    EQUIPMENT_PURCHASE = "equipment_purchase"
    LAND_PURCHASE = "land_purchase"
    WORKING_CAPITAL = "working_capital"
    EMERGENCY = "emergency"
    SEASONAL = "seasonal"
    DEVELOPMENT = "development"


class LoanStatusEnum(str, Enum):
    DRAFT = "draft"
    SUBMITTED = "submitted"
    UNDER_REVIEW = "under_review"
    APPROVED = "approved"
    REJECTED = "rejected"
    DISBURSED = "disbursed"
    ACTIVE = "active"
    COMPLETED = "completed"
    DEFAULTED = "defaulted"


class PaymentStatusEnum(str, Enum):
    PENDING = "pending"
    PAID = "paid"
    OVERDUE = "overdue"
    PARTIAL = "partial"
    WAIVED = "waived"


class InsuranceTypeEnum(str, Enum):
    CROP_INSURANCE = "crop_insurance"
    LIVESTOCK_INSURANCE = "livestock_insurance"
    EQUIPMENT_INSURANCE = "equipment_insurance"
    WEATHER_INDEX = "weather_index"
    YIELD_PROTECTION = "yield_protection"
    REVENUE_PROTECTION = "revenue_protection"


class ClaimStatusEnum(str, Enum):
    DRAFT = "draft"
    SUBMITTED = "submitted"
    UNDER_INVESTIGATION = "under_investigation"
    APPROVED = "approved"
    REJECTED = "rejected"
    PAID = "paid"
    CLOSED = "closed"


# Financial Institution Schemas
class FinancialInstitutionBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    type: Optional[str] = None
    address: Optional[str] = None
    phone_number: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None
    license_number: Optional[str] = None
    regulatory_body: Optional[str] = None
    is_licensed: bool = True
    offers_loans: bool = True
    offers_savings: bool = True
    offers_insurance: bool = False
    offers_mobile_banking: bool = False
    min_loan_amount: Optional[float] = Field(None, gt=0)
    max_loan_amount: Optional[float] = Field(None, gt=0)
    min_interest_rate: Optional[float] = Field(None, ge=0, le=100)
    max_interest_rate: Optional[float] = Field(None, ge=0, le=100)
    max_loan_term_months: Optional[int] = Field(None, gt=0)
    min_credit_score: Optional[float] = Field(None, ge=0)
    requires_collateral: bool = True
    requires_guarantor: bool = False
    min_farming_experience_years: Optional[int] = Field(None, ge=0)


class FinancialInstitutionCreate(FinancialInstitutionBase):
    pass


class FinancialInstitutionUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    type: Optional[str] = None
    phone_number: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None
    offers_loans: Optional[bool] = None
    offers_savings: Optional[bool] = None
    offers_insurance: Optional[bool] = None
    min_loan_amount: Optional[float] = Field(None, gt=0)
    max_loan_amount: Optional[float] = Field(None, gt=0)
    min_interest_rate: Optional[float] = Field(None, ge=0, le=100)
    max_interest_rate: Optional[float] = Field(None, ge=0, le=100)


class FinancialInstitutionResponse(FinancialInstitutionBase):
    id: int
    approval_rate_percentage: Optional[float] = None
    average_processing_days: Optional[int] = None
    customer_satisfaction_rating: Optional[float] = None
    default_rate_percentage: Optional[float] = None
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Loan Application Schemas
class LoanApplicationBase(BaseModel):
    loan_type: LoanTypeEnum
    requested_amount: float = Field(..., gt=0)
    currency: str = Field("KES", min_length=3, max_length=3)
    requested_term_months: int = Field(..., gt=0)
    purpose: str = Field(..., min_length=1)
    monthly_income: Optional[float] = Field(None, ge=0)
    annual_farm_revenue: Optional[float] = Field(None, ge=0)
    existing_debt: Optional[float] = Field(None, ge=0)
    credit_score: Optional[float] = Field(None, ge=0)
    farming_experience_years: Optional[int] = Field(None, ge=0)
    collateral_type: Optional[str] = None
    collateral_value: Optional[float] = Field(None, ge=0)
    collateral_description: Optional[str] = None
    guarantor_name: Optional[str] = None
    guarantor_phone: Optional[str] = None
    guarantor_relationship: Optional[str] = None
    guarantor_income: Optional[float] = Field(None, ge=0)
    farm_size_hectares: Optional[float] = Field(None, gt=0)
    primary_crops: Optional[List[str]] = None
    expected_yield: Optional[float] = Field(None, ge=0)
    expected_revenue: Optional[float] = Field(None, ge=0)


class LoanApplicationCreate(LoanApplicationBase):
    financial_institution_id: int


class LoanApplicationUpdate(BaseModel):
    monthly_income: Optional[float] = Field(None, ge=0)
    annual_farm_revenue: Optional[float] = Field(None, ge=0)
    existing_debt: Optional[float] = Field(None, ge=0)
    collateral_value: Optional[float] = Field(None, ge=0)
    collateral_description: Optional[str] = None
    expected_yield: Optional[float] = Field(None, ge=0)
    expected_revenue: Optional[float] = Field(None, ge=0)


class LoanApplicationResponse(LoanApplicationBase):
    id: int
    applicant_id: int
    financial_institution_id: int
    approved_amount: Optional[float] = None
    approved_term_months: Optional[int] = None
    interest_rate: Optional[float] = None
    processing_fee: Optional[float] = None
    insurance_fee: Optional[float] = None
    monthly_payment: Optional[float] = None
    first_payment_date: Optional[datetime] = None
    final_payment_date: Optional[datetime] = None
    grace_period_months: Optional[int] = None
    status: LoanStatusEnum
    application_date: datetime
    review_start_date: Optional[datetime] = None
    decision_date: Optional[datetime] = None
    disbursement_date: Optional[datetime] = None
    approval_notes: Optional[str] = None
    rejection_reason: Optional[str] = None
    conditions: Optional[List[str]] = None
    risk_score: Optional[float] = None
    risk_factors: Optional[List[str]] = None
    mitigation_measures: Optional[List[str]] = None
    documents_submitted: Optional[List[str]] = None
    documents_verified: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Loan Schemas
class LoanBase(BaseModel):
    loan_number: str = Field(..., min_length=1, max_length=100)
    principal_amount: float = Field(..., gt=0)
    interest_rate: float = Field(..., ge=0, le=100)
    term_months: int = Field(..., gt=0)
    disbursement_date: datetime
    disbursement_method: Optional[str] = None
    disbursed_amount: Optional[float] = Field(None, gt=0)
    payment_frequency: Optional[str] = None
    monthly_payment: Optional[float] = Field(None, gt=0)
    total_payments: Optional[int] = Field(None, gt=0)
    first_payment_date: Optional[datetime] = None
    final_payment_date: Optional[datetime] = None


class LoanCreate(LoanBase):
    application_id: int
    borrower_id: int
    lender_id: int


class LoanUpdate(BaseModel):
    outstanding_balance: Optional[float] = Field(None, ge=0)
    payments_made: Optional[int] = Field(None, ge=0)
    total_paid: Optional[float] = Field(None, ge=0)
    last_payment_date: Optional[datetime] = None
    next_payment_date: Optional[datetime] = None
    days_overdue: Optional[int] = Field(None, ge=0)
    missed_payments: Optional[int] = Field(None, ge=0)
    late_payments: Optional[int] = Field(None, ge=0)
    is_restructured: Optional[bool] = None
    restructure_date: Optional[datetime] = None
    restructure_reason: Optional[str] = None


class LoanResponse(LoanBase):
    id: int
    application_id: int
    borrower_id: int
    lender_id: int
    outstanding_balance: Optional[float] = None
    payments_made: int
    total_paid: float
    last_payment_date: Optional[datetime] = None
    next_payment_date: Optional[datetime] = None
    days_overdue: int
    missed_payments: int
    late_payments: int
    payment_history_score: Optional[float] = None
    is_active: bool
    is_restructured: bool
    restructure_date: Optional[datetime] = None
    restructure_reason: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Loan Payment Schemas
class LoanPaymentBase(BaseModel):
    payment_date: datetime
    due_date: datetime
    amount_due: float = Field(..., gt=0)
    amount_paid: float = Field(..., ge=0)
    principal_payment: Optional[float] = Field(None, ge=0)
    interest_payment: Optional[float] = Field(None, ge=0)
    penalty_payment: Optional[float] = Field(None, ge=0)
    fees_payment: Optional[float] = Field(None, ge=0)
    payment_method: Optional[str] = None
    transaction_reference: Optional[str] = None
    payment_channel: Optional[str] = None
    notes: Optional[str] = None


class LoanPaymentCreate(LoanPaymentBase):
    loan_id: int


class LoanPaymentUpdate(BaseModel):
    status: Optional[PaymentStatusEnum] = None
    amount_paid: Optional[float] = Field(None, ge=0)
    payment_method: Optional[str] = None
    transaction_reference: Optional[str] = None
    notes: Optional[str] = None


class LoanPaymentResponse(LoanPaymentBase):
    id: int
    loan_id: int
    status: PaymentStatusEnum
    is_late: bool
    days_late: int
    remaining_balance: Optional[float] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Insurance Policy Schemas
class InsurancePolicyBase(BaseModel):
    policy_number: str = Field(..., min_length=1, max_length=100)
    insurance_type: InsuranceTypeEnum
    coverage_amount: float = Field(..., gt=0)
    premium_amount: float = Field(..., gt=0)
    deductible_amount: float = Field(0.0, ge=0)
    start_date: datetime
    end_date: datetime
    policy_term_months: Optional[int] = Field(None, gt=0)
    covered_crops: Optional[List[str]] = None
    covered_area_hectares: Optional[float] = Field(None, gt=0)
    covered_risks: Optional[List[str]] = None
    exclusions: Optional[List[str]] = None
    premium_frequency: Optional[str] = None
    premium_due_date: Optional[datetime] = None
    weather_station_id: Optional[str] = None
    trigger_conditions: Optional[Dict[str, Any]] = None
    payout_structure: Optional[Dict[str, Any]] = None
    guaranteed_yield_kg_per_ha: Optional[float] = Field(None, ge=0)
    historical_yield_average: Optional[float] = Field(None, ge=0)
    coverage_level_percentage: Optional[float] = Field(None, ge=0, le=100)


class InsurancePolicyCreate(InsurancePolicyBase):
    policyholder_id: int
    provider_id: int


class InsurancePolicyUpdate(BaseModel):
    coverage_amount: Optional[float] = Field(None, gt=0)
    premium_amount: Optional[float] = Field(None, gt=0)
    covered_crops: Optional[List[str]] = None
    covered_area_hectares: Optional[float] = Field(None, gt=0)
    premium_paid: Optional[bool] = None
    premium_payment_date: Optional[datetime] = None
    is_renewable: Optional[bool] = None


class InsurancePolicyResponse(InsurancePolicyBase):
    id: int
    policyholder_id: int
    provider_id: int
    premium_paid: bool
    premium_payment_date: Optional[datetime] = None
    is_active: bool
    is_renewable: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Insurance Claim Schemas
class InsuranceClaimBase(BaseModel):
    claim_number: str = Field(..., min_length=1, max_length=100)
    incident_date: datetime
    reported_date: datetime
    claim_amount: float = Field(..., gt=0)
    cause_of_loss: str = Field(..., min_length=1, max_length=200)
    incident_description: str = Field(..., min_length=1)
    affected_area_hectares: Optional[float] = Field(None, gt=0)
    estimated_yield_loss_kg: Optional[float] = Field(None, ge=0)
    estimated_yield_loss_percentage: Optional[float] = Field(None, ge=0, le=100)
    photos_submitted: Optional[List[str]] = None
    documents_submitted: Optional[List[str]] = None
    witness_statements: Optional[List[str]] = None
    expert_reports: Optional[List[str]] = None
    weather_data_at_incident: Optional[Dict[str, Any]] = None
    weather_station_readings: Optional[Dict[str, Any]] = None


class InsuranceClaimCreate(InsuranceClaimBase):
    policy_id: int


class InsuranceClaimUpdate(BaseModel):
    assessor_name: Optional[str] = None
    assessment_date: Optional[datetime] = None
    assessment_report: Optional[str] = None
    assessed_loss_amount: Optional[float] = Field(None, ge=0)
    assessment_photos: Optional[List[str]] = None
    status: Optional[ClaimStatusEnum] = None
    decision_date: Optional[datetime] = None
    approved_amount: Optional[float] = Field(None, ge=0)
    rejection_reason: Optional[str] = None
    payment_date: Optional[datetime] = None
    payment_method: Optional[str] = None
    payment_reference: Optional[str] = None


class InsuranceClaimResponse(InsuranceClaimBase):
    id: int
    policy_id: int
    claimant_id: int
    assessor_name: Optional[str] = None
    assessment_date: Optional[datetime] = None
    assessment_report: Optional[str] = None
    assessed_loss_amount: Optional[float] = None
    assessment_photos: Optional[List[str]] = None
    status: ClaimStatusEnum
    decision_date: Optional[datetime] = None
    approved_amount: Optional[float] = None
    rejection_reason: Optional[str] = None
    payment_date: Optional[datetime] = None
    payment_method: Optional[str] = None
    payment_reference: Optional[str] = None
    appeal_submitted: bool
    appeal_date: Optional[datetime] = None
    appeal_reason: Optional[str] = None
    appeal_decision: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Financial Transaction Schemas
class FinancialTransactionBase(BaseModel):
    transaction_type: str = Field(..., min_length=1, max_length=100)
    category: Optional[str] = None
    subcategory: Optional[str] = None
    amount: float = Field(..., ne=0)  # Can be negative for expenses
    currency: str = Field("KES", min_length=3, max_length=3)
    transaction_date: datetime
    description: Optional[str] = None
    reference_number: Optional[str] = None
    payment_method: Optional[str] = None
    payee_payer: Optional[str] = None
    receipt_url: Optional[str] = None
    invoice_url: Optional[str] = None
    is_tax_deductible: bool = False
    tax_category: Optional[str] = None
    vat_amount: Optional[float] = Field(None, ge=0)
    budget_category: Optional[str] = None
    is_planned_expense: bool = False
    variance_from_budget: Optional[float] = None


class FinancialTransactionCreate(FinancialTransactionBase):
    farm_id: Optional[int] = None
    field_id: Optional[int] = None
    crop_id: Optional[int] = None


class FinancialTransactionUpdate(BaseModel):
    category: Optional[str] = None
    subcategory: Optional[str] = None
    description: Optional[str] = None
    receipt_url: Optional[str] = None
    invoice_url: Optional[str] = None
    is_tax_deductible: Optional[bool] = None
    tax_category: Optional[str] = None
    budget_category: Optional[str] = None


class FinancialTransactionResponse(FinancialTransactionBase):
    id: int
    user_id: int
    farm_id: Optional[int] = None
    field_id: Optional[int] = None
    crop_id: Optional[int] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Budget Schemas
class BudgetBase(BaseModel):
    budget_name: str = Field(..., min_length=1, max_length=200)
    budget_type: Optional[str] = None
    start_date: datetime
    end_date: datetime
    total_budget: float = Field(..., gt=0)
    income_budget: Optional[float] = Field(None, ge=0)
    expense_budget: Optional[float] = Field(None, ge=0)
    budget_items: Optional[Dict[str, Any]] = None
    notes: Optional[str] = None

    @validator('end_date')
    def validate_end_date(cls, v, values):
        if 'start_date' in values and v <= values['start_date']:
            raise ValueError('End date must be after start date')
        return v


class BudgetCreate(BudgetBase):
    farm_id: Optional[int] = None


class BudgetUpdate(BaseModel):
    budget_name: Optional[str] = Field(None, min_length=1, max_length=200)
    total_budget: Optional[float] = Field(None, gt=0)
    income_budget: Optional[float] = Field(None, ge=0)
    expense_budget: Optional[float] = Field(None, ge=0)
    budget_items: Optional[Dict[str, Any]] = None
    is_approved: Optional[bool] = None
    approved_by: Optional[str] = None
    approved_date: Optional[datetime] = None
    notes: Optional[str] = None


class BudgetResponse(BudgetBase):
    id: int
    user_id: int
    farm_id: Optional[int] = None
    actual_income: float
    actual_expenses: float
    variance_percentage: Optional[float] = None
    is_active: bool
    is_approved: bool
    approved_by: Optional[str] = None
    approved_date: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Financial Analysis Schemas
class FinancialAnalysisRequest(BaseModel):
    analysis_type: str = Field(..., regex="^(cash_flow|profitability|budget_variance|loan_analysis)$")
    time_period_months: int = Field(12, ge=1, le=60)
    farm_id: Optional[int] = None
    crop_id: Optional[int] = None
    include_projections: bool = False


class CashFlowAnalysis(BaseModel):
    period: str
    total_income: float
    total_expenses: float
    net_cash_flow: float
    operating_cash_flow: float
    investment_cash_flow: float
    financing_cash_flow: float
    cash_flow_trend: str
    liquidity_ratio: Optional[float] = None
    recommendations: List[str]


class ProfitabilityAnalysis(BaseModel):
    period: str
    total_revenue: float
    total_costs: float
    gross_profit: float
    net_profit: float
    profit_margin_percentage: float
    return_on_investment: Optional[float] = None
    cost_per_hectare: Optional[float] = None
    revenue_per_hectare: Optional[float] = None
    break_even_analysis: Dict[str, Any]
    profitability_trend: str
    recommendations: List[str]


# Financial Statistics
class FinancialStatistics(BaseModel):
    total_transactions: int
    total_income: float
    total_expenses: float
    net_income: float
    active_loans: int
    total_loan_amount: float
    outstanding_loan_balance: float
    active_insurance_policies: int
    total_insurance_coverage: float
    budget_variance_percentage: Optional[float] = None
    cash_flow_trend: str
    profitability_trend: str
    financial_health_score: float = Field(..., ge=0, le=100)