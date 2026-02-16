class DingleExpense < ApplicationRecord
  GUESTS = %w[Megan Thibault Jordan].freeze
  
  validates :payer, presence: true, inclusion: { in: GUESTS }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expense_date, presence: true
  
  before_validation :set_default_expense_date
  before_validation :set_default_split_between
  
  scope :ordered, -> { order(expense_date: :asc, created_at: :asc) }
  scope :grouped_by_date, -> { ordered.group_by(&:expense_date) }
  
  # Returns array of guests this expense is split between
  def split_guests
    (split_between || GUESTS.join(',')).split(',')
  end
  
  # Check if a specific guest is included in the split
  def includes_guest?(guest)
    split_guests.include?(guest)
  end
  
  # Returns number of people splitting this expense
  def split_count
    split_guests.count
  end
  
  # Returns how much each person owes for this expense
  def per_person_amount
    return 0 if split_count.zero?
    amount.to_f / split_count
  end
  
  def self.calculate_settlements
    # Track what each person paid and what each person owes
    paid = GUESTS.index_with { |_| 0.0 }
    owes = GUESTS.index_with { |_| 0.0 }
    
    all.each do |expense|
      # Add what this person paid
      paid[expense.payer] += expense.amount.to_f
      
      # Add what each included person owes
      per_person = expense.per_person_amount
      expense.split_guests.each do |guest|
        owes[guest] += per_person
      end
    end
    
    grand_total = paid.values.sum
    
    # Calculate balances (positive = owed money back, negative = owes money)
    # Balance = what you paid - what you owe
    balances = GUESTS.index_with { |guest| paid[guest] - owes[guest] }
    
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
    
    # Calculate fair share only for comparison (not used in actual settlement)
    fair_share = GUESTS.count > 0 ? grand_total / GUESTS.count : 0
    
    {
      totals: paid,
      owes: owes,
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
  
  def set_default_split_between
    self.split_between ||= GUESTS.join(',')
  end
end
