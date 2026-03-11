from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Float, JSON, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
import enum


class LoanType(enum.Enum):
    CROP_PRODUCTION = "crop_production"
    EQUIPMENT_PURCHASE = "equipment_purchase"
    LAND_PURCHASE = "land_purchase"
    WORKING_CAPITAL = "working_capital"
    EMERGENCY = "emergency"
    SEASONAL = "seasonal"
    DEVELOPMENT = "development"


class LoanStatus(enum.Enum):
    DRAFT = "draft"
    SUBMITTED = "submitted"
    UNDER_REVIEW = "under_review"
    APPROVED = "approved"
    REJECTED = "rejected"
    DISBURSED = "disbursed"
    ACTIVE = "active"
    COMPLETED = "completed"
    DEFAULTED = "defaulted"


class PaymentStatus(enum.Enum):
    PENDING = "pending"
    PAID = "paid"
    OVERDUE = "overdue"
    PARTIAL = "partial"
    WAIVED = "waived"


class InsuranceType(enum.Enum):
    CROP_INSURANCE = "crop_insurance"
    LIVESTOCK_INSURANCE = "livestock_insurance"
    EQUIPMENT_INSURANCE = "equipment_insurance"
    WEATHER_INDEX = "weather_index"
    YIELD_PROTECTION = "yield_protection"
    REVENUE_PROTECTION = "revenue_protection"


class ClaimStatus(enum.Enum):
    DRAFT = "draft"
    SUBMITTED = "submitted"
    UNDER_INVESTIGATION = "under_investigation"
    APPROVED = "approved"
    REJECTED = "rejected"
    PAID = "paid"
    CLOSED = "closed"


class FinancialInstitution(Base):
    __tablename__ = "financial_institutions"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    type = Column(String(100))  # bank, microfinance, cooperative, sacco, mobile_money
    
    # Contact information
    address = Column(Text)
    phone_number = Column(String(20))
    email = Column(String(255))
    website = Column(String(500))
    
    # Licensing and regulation
    license_number = Column(String(100))
    regulatory_body = Column(String(200))
    is_licensed = Column(Boolean, default=True)
    
    # Services offered
    offers_loans = Column(Boolean, default=True)
    offers_savings = Column(Boolean, default=True)
    offers_insurance = Column(Boolean, default=False)
    offers_mobile_banking = Column(Boolean, default=False)
    
    # Loan products
    min_loan_amount = Column(Float)
    max_loan_amount = Column(Float)
    min_interest_rate = Column(Float)
    max_interest_rate = Column(Float)
    max_loan_term_months = Column(Integer)
    
    # Requirements
    min_credit_score = Column(Float)
    requires_collateral = Column(Boolean, default=True)
    requires_guarantor = Column(Boolean, default=False)
    min_farming_experience_years = Column(Integer)
    
    # Performance metrics
    approval_rate_percentage = Column(Float)
    average_processing_days = Column(Integer)
    customer_satisfaction_rating = Column(Float)
    default_rate_percentage = Column(Float)
    
    # Status
    is_active = Column(Boolean, default=True)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    loan_applications = relationship("LoanApplication", back_populates="financial_institution")
    insurance_policies = relationship("InsurancePolicy", back_populates="provider")


class LoanApplication(Base):
    __tablename__ = "loan_applications"
    
    id = Column(Integer, primary_key=True, index=True)
    applicant_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    financial_institution_id = Column(Integer, ForeignKey("financial_institutions.id"), nullable=False)
    
    # Application details
    loan_type = Column(Enum(LoanType), nullable=False)
    requested_amount = Column(Float, nullable=False)
    currency = Column(String(10), default="KES")
    requested_term_months = Column(Integer, nullable=False)
    purpose = Column(Text, nullable=False)
    
    # Applicant information
    monthly_income = Column(Float)
    annual_farm_revenue = Column(Float)
    existing_debt = Column(Float)
    credit_score = Column(Float)
    farming_experience_years = Column(Integer)
    
    # Collateral information
    collateral_type = Column(String(200))
    collateral_value = Column(Float)
    collateral_description = Column(Text)
    
    # Guarantor information
    guarantor_name = Column(String(200))
    guarantor_phone = Column(String(20))
    guarantor_relationship = Column(String(100))
    guarantor_income = Column(Float)
    
    # Farm information
    farm_size_hectares = Column(Float)
    primary_crops = Column(JSON)
    expected_yield = Column(Float)
    expected_revenue = Column(Float)
    
    # Loan terms (filled after approval)
    approved_amount = Column(Float)
    approved_term_months = Column(Integer)
    interest_rate = Column(Float)
    processing_fee = Column(Float)
    insurance_fee = Column(Float)
    
    # Repayment schedule
    monthly_payment = Column(Float)
    first_payment_date = Column(DateTime)
    final_payment_date = Column(DateTime)
    grace_period_months = Column(Integer)
    
    # Status tracking
    status = Column(Enum(LoanStatus), default=LoanStatus.DRAFT)
    application_date = Column(DateTime, nullable=False)
    review_start_date = Column(DateTime)
    decision_date = Column(DateTime)
    disbursement_date = Column(DateTime)
    
    # Decision information
    approval_notes = Column(Text)
    rejection_reason = Column(Text)
    conditions = Column(JSON)  # Any conditions attached to approval
    
    # Risk assessment
    risk_score = Column(Float)  # 0-1, higher is riskier
    risk_factors = Column(JSON)
    mitigation_measures = Column(JSON)
    
    # Documentation
    documents_submitted = Column(JSON)  # List of document types submitted
    documents_verified = Column(Boolean, default=False)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    applicant = relationship("User", back_populates="loan_applications")
    financial_institution = relationship("FinancialInstitution", back_populates="loan_applications")
    loan = relationship("Loan", back_populates="application", uselist=False)


class Loan(Base):
    __tablename__ = "loans"
    
    id = Column(Integer, primary_key=True, index=True)
    application_id = Column(Integer, ForeignKey("loan_applications.id"), nullable=False)
    borrower_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    lender_id = Column(Integer, ForeignKey("financial_institutions.id"), nullable=False)
    
    # Loan details
    loan_number = Column(String(100), unique=True, nullable=False)
    principal_amount = Column(Float, nullable=False)
    interest_rate = Column(Float, nullable=False)
    term_months = Column(Integer, nullable=False)
    
    # Disbursement
    disbursement_date = Column(DateTime, nullable=False)
    disbursement_method = Column(String(100))  # bank_transfer, mobile_money, cash
    disbursed_amount = Column(Float)  # May be less than principal due to fees
    
    # Repayment terms
    payment_frequency = Column(String(50))  # monthly, quarterly, seasonal
    monthly_payment = Column(Float)
    total_payments = Column(Integer)
    first_payment_date = Column(DateTime)
    final_payment_date = Column(DateTime)
    
    # Current status
    outstanding_balance = Column(Float)
    payments_made = Column(Integer, default=0)
    total_paid = Column(Float, default=0.0)
    last_payment_date = Column(DateTime)
    next_payment_date = Column(DateTime)
    
    # Performance tracking
    days_overdue = Column(Integer, default=0)
    missed_payments = Column(Integer, default=0)
    late_payments = Column(Integer, default=0)
    payment_history_score = Column(Float)  # 0-1
    
    # Status
    is_active = Column(Boolean, default=True)
    is_restructured = Column(Boolean, default=False)
    restructure_date = Column(DateTime)
    restructure_reason = Column(Text)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    application = relationship("LoanApplication", back_populates="loan")
    borrower = relationship("User", foreign_keys=[borrower_id])
    lender = relationship("FinancialInstitution", foreign_keys=[lender_id])
    payments = relationship("LoanPayment", back_populates="loan")


class LoanPayment(Base):
    __tablename__ = "loan_payments"
    
    id = Column(Integer, primary_key=True, index=True)
    loan_id = Column(Integer, ForeignKey("loans.id"), nullable=False)
    
    # Payment details
    payment_date = Column(DateTime, nullable=False)
    due_date = Column(DateTime, nullable=False)
    amount_due = Column(Float, nullable=False)
    amount_paid = Column(Float, nullable=False)
    
    # Payment breakdown
    principal_payment = Column(Float)
    interest_payment = Column(Float)
    penalty_payment = Column(Float, default=0.0)
    fees_payment = Column(Float, default=0.0)
    
    # Payment method
    payment_method = Column(String(100))  # bank_transfer, mobile_money, cash, check
    transaction_reference = Column(String(200))
    payment_channel = Column(String(100))
    
    # Status
    status = Column(Enum(PaymentStatus), default=PaymentStatus.PENDING)
    is_late = Column(Boolean, default=False)
    days_late = Column(Integer, default=0)
    
    # Outstanding after payment
    remaining_balance = Column(Float)
    
    # Metadata
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    loan = relationship("Loan", back_populates="payments")


class InsurancePolicy(Base):
    __tablename__ = "insurance_policies"
    
    id = Column(Integer, primary_key=True, index=True)
    policyholder_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    provider_id = Column(Integer, ForeignKey("financial_institutions.id"), nullable=False)
    
    # Policy details
    policy_number = Column(String(100), unique=True, nullable=False)
    insurance_type = Column(Enum(InsuranceType), nullable=False)
    coverage_amount = Column(Float, nullable=False)
    premium_amount = Column(Float, nullable=False)
    deductible_amount = Column(Float, default=0.0)
    
    # Coverage period
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=False)
    policy_term_months = Column(Integer)
    
    # Coverage details
    covered_crops = Column(JSON)  # For crop insurance
    covered_area_hectares = Column(Float)
    covered_risks = Column(JSON)  # List of covered perils
    exclusions = Column(JSON)  # List of exclusions
    
    # Premium payment
    premium_frequency = Column(String(50))  # annual, semi_annual, quarterly
    premium_due_date = Column(DateTime)
    premium_paid = Column(Boolean, default=False)
    premium_payment_date = Column(DateTime)
    
    # Weather index parameters (for weather-based insurance)
    weather_station_id = Column(String(100))
    trigger_conditions = Column(JSON)  # Weather conditions that trigger payout
    payout_structure = Column(JSON)  # How payouts are calculated
    
    # Yield protection parameters
    guaranteed_yield_kg_per_ha = Column(Float)
    historical_yield_average = Column(Float)
    coverage_level_percentage = Column(Float)  # e.g., 70% of historical yield
    
    # Status
    is_active = Column(Boolean, default=True)
    is_renewable = Column(Boolean, default=True)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    policyholder = relationship("User")
    provider = relationship("FinancialInstitution", back_populates="insurance_policies")
    claims = relationship("InsuranceClaim", back_populates="policy")


class InsuranceClaim(Base):
    __tablename__ = "insurance_claims"
    
    id = Column(Integer, primary_key=True, index=True)
    policy_id = Column(Integer, ForeignKey("insurance_policies.id"), nullable=False)
    claimant_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Claim details
    claim_number = Column(String(100), unique=True, nullable=False)
    incident_date = Column(DateTime, nullable=False)
    reported_date = Column(DateTime, nullable=False)
    claim_amount = Column(Float, nullable=False)
    
    # Incident information
    cause_of_loss = Column(String(200), nullable=False)
    incident_description = Column(Text, nullable=False)
    affected_area_hectares = Column(Float)
    estimated_yield_loss_kg = Column(Float)
    estimated_yield_loss_percentage = Column(Float)
    
    # Supporting evidence
    photos_submitted = Column(JSON)  # URLs to photos
    documents_submitted = Column(JSON)  # List of supporting documents
    witness_statements = Column(JSON)
    expert_reports = Column(JSON)
    
    # Weather data (for weather-related claims)
    weather_data_at_incident = Column(JSON)
    weather_station_readings = Column(JSON)
    
    # Assessment
    assessor_name = Column(String(200))
    assessment_date = Column(DateTime)
    assessment_report = Column(Text)
    assessed_loss_amount = Column(Float)
    assessment_photos = Column(JSON)
    
    # Decision
    status = Column(Enum(ClaimStatus), default=ClaimStatus.DRAFT)
    decision_date = Column(DateTime)
    approved_amount = Column(Float)
    rejection_reason = Column(Text)
    
    # Payment
    payment_date = Column(DateTime)
    payment_method = Column(String(100))
    payment_reference = Column(String(200))
    
    # Appeals and disputes
    appeal_submitted = Column(Boolean, default=False)
    appeal_date = Column(DateTime)
    appeal_reason = Column(Text)
    appeal_decision = Column(Text)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    policy = relationship("InsurancePolicy", back_populates="claims")
    claimant = relationship("User")


class FinancialTransaction(Base):
    __tablename__ = "financial_transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Transaction details
    transaction_type = Column(String(100), nullable=False)  # income, expense, loan_payment, insurance_premium
    category = Column(String(100))  # seeds, fertilizer, labor, equipment, etc.
    subcategory = Column(String(100))
    
    # Amount and currency
    amount = Column(Float, nullable=False)
    currency = Column(String(10), default="KES")
    
    # Transaction information
    transaction_date = Column(DateTime, nullable=False)
    description = Column(Text)
    reference_number = Column(String(200))
    
    # Related entities
    farm_id = Column(Integer, ForeignKey("farms.id"))
    field_id = Column(Integer, ForeignKey("fields.id"))
    crop_id = Column(Integer, ForeignKey("crops.id"))
    
    # Payment details
    payment_method = Column(String(100))
    payee_payer = Column(String(200))  # Who was paid or who paid
    
    # Receipts and documentation
    receipt_url = Column(String(500))
    invoice_url = Column(String(500))
    
    # Tax and accounting
    is_tax_deductible = Column(Boolean, default=False)
    tax_category = Column(String(100))
    vat_amount = Column(Float, default=0.0)
    
    # Budget tracking
    budget_category = Column(String(100))
    is_planned_expense = Column(Boolean, default=False)
    variance_from_budget = Column(Float)
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    user = relationship("User")
    farm = relationship("Farm")
    field = relationship("Field")
    crop = relationship("Crop")


class Budget(Base):
    __tablename__ = "budgets"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    farm_id = Column(Integer, ForeignKey("farms.id"))
    
    # Budget details
    budget_name = Column(String(200), nullable=False)
    budget_type = Column(String(100))  # annual, seasonal, crop_specific, project
    
    # Time period
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=False)
    
    # Budget categories and amounts
    total_budget = Column(Float, nullable=False)
    income_budget = Column(Float)
    expense_budget = Column(Float)
    
    # Detailed budget breakdown
    budget_items = Column(JSON)  # Detailed line items with categories and amounts
    
    # Tracking
    actual_income = Column(Float, default=0.0)
    actual_expenses = Column(Float, default=0.0)
    variance_percentage = Column(Float)
    
    # Status
    is_active = Column(Boolean, default=True)
    is_approved = Column(Boolean, default=False)
    approved_by = Column(String(200))
    approved_date = Column(DateTime)
    
    # Metadata
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    user = relationship("User")
    farm = relationship("Farm")