class DingleExpense < ApplicationRecord
  GUESTS = %w[Megan Thibaut Jordan].freeze
  
  validates :payer, presence: true, inclusion: { in: GUESTS }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expense_date, presence: true
  
  before_validation :set_default_expense_date
  
  scope :ordered, -> { order(expense_date: :asc, created_at: :asc) }
  scope :grouped_by_date, -> { ordered.group_by(&:expense_date) }
  
  def self.calculate_settlements
    # Calculate total spent by each person
    totals = GUESTS.index_with { |_| 0.0 }
    
    all.each do |expense|
      totals[expense.payer] += expense.amount.to_f
    end
    
    grand_total = totals.values.sum
    fair_share = grand_total / GUESTS.count
    
    # Calculate balances (positive = owed money, negative = owes money)
    balances = GUESTS.index_with { |guest| totals[guest] - fair_share }
    
    # Simplify debts - who owes who
    settlements = []
    creditors = balances.select { |_, v| v > 0.01 }.sort_by { |_, v| -v }
    debtors = balances.select { |_, v| v < -0.01 }.sort_by { |_, v| v }
    
    creditors_copy = creditors.to_h.dup
    debtors_copy = debtors.to_h.dup
    
    debtors_copy.each do |debtor, debt|
      remaining_debt = debt.abs
      
      creditors_copy.each do |creditor, credit|
        next if credit <= 0.01 || remaining_debt <= 0.01
        
        payment = [remaining_debt, credit].min
        
        if payment > 0.01
          settlements << {
            from: debtor,
            to: creditor,
            amount: payment.round(2)
          }
          
          remaining_debt -= payment
          creditors_copy[creditor] -= payment
        end
      end
    end
    
    {
      totals: totals,
      grand_total: grand_total,
      fair_share: fair_share.round(2),
      balances: balances.transform_values { |v| v.round(2) },
      settlements: settlements
    }
  end
  
  private
  
  def set_default_expense_date
    self.expense_date ||= Date.today
  end
end
