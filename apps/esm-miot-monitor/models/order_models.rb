module EsmMiotMonitor

class Order < GXTModel
  include Mongoid::Document
  include Mongoid::Timestamps

  # ความสัมพันธ์
  belongs_to :admit, class_name: 'EsmMiotMonitor::Admit'
  belongs_to :provider, class_name: 'EsmMiotMonitor::Provider'  # แพทย์ผู้สั่ง
  belongs_to :created_user, class_name: 'EsmMiotMonitor::User'
  belongs_to :updated_user, class_name: 'EsmMiotMonitor::User'
  has_many :order_items, class_name: 'EsmMiotMonitor::OrderItem'

  # ฟิลด์
  key :admit_id, ObjectId
  key :provider_id, ObjectId
  key :created_user_id, ObjectId 
  key :updated_user_id, ObjectId
  
  key :order_number, String  # เลขที่คำสั่ง
  key :order_type, String   # ประเภทคำสั่ง (เช่น medication, lab, xray)
  key :priority, String     # ความเร่งด่วน (stat, routine)
  key :status, String      # สถานะ (pending, approved, completed, cancelled)
  key :note, String        # หมายเหตุ
  key :order_date, Time    # วันที่สั่ง
  
  # Validations
  # validates :admit_id, presence: true
  # validates :provider_id, presence: true
  # validates :order_number, presence: true
  # validates :order_type, presence: true
  # validates :status, presence: true

  # Callbacks
  before_create :generate_order_number
  
  private
  
  def generate_order_number
    # สร้างเลขที่คำสั่งอัตโนมัติ
    date_prefix = Time.now.strftime('%Y%m%d')
    # counter = Counter.get("order_#{date_prefix}", self.admit.unit_id)
    counter = Counter.get("order_#{date_prefix}")

    self.order_number = "#{date_prefix}#{format('%04d', counter)}"
  end
end

class OrderItem < GXTModel
  include Mongoid::Document
  include Mongoid::Timestamps

  # ความสัมพันธ์
  belongs_to :order, class_name: 'EsmMiotMonitor::Order'
  belongs_to :product, class_name: 'EsmMiotMonitor::Product'
  belongs_to :created_user, class_name: 'EsmMiotMonitor::User'
  belongs_to :updated_user, class_name: 'EsmMiotMonitor::User'

  # ฟิลด์
  key :order_id, ObjectId
  key :product_id, ObjectId
  key :created_user_id, ObjectId
  key :updated_user_id, ObjectId
  
  key :quantity, Float    # จำนวน
  key :unit, String      # หน่วย
  key :frequency, String # ความถี่การให้ยา
  key :duration, Integer # ระยะเวลา
  key :duration_unit, String # หน่วยของระยะเวลา (วัน/สัปดาห์)
  key :instruction, String  # คำแนะนำการใช้
  key :status, String    # สถานะรายการ
  key :note, String      # หมายเหตุ
  
  # Validations
  validates :order_id, presence: true
  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  has_many :status_logs, class_name: 'EsmMiotMonitor::OrderItemStatusLog'

  # เพิ่ม method สำหรับอัพเดทสถานะ
  def update_status(new_status, user_id = nil, note = nil)
    return false if new_status == self.status # ไม่มีการเปลี่ยนแปลง

    # สร้างล็อกใหม่
    log = self.status_logs.create(
      created_user_id: user_id,
      previous_status: self.status,
      new_status: new_status,
      note: note
    )

    # อัพเดทสถานะปัจจุบัน
    self.status = new_status
    self.save
  end

  # เพิ่ม method สำหรับดูระยะเวลาในแต่ละสถานะ
  def status_durations
    durations = {}
    
    self.status_logs.each do |log|
      status = log.new_status
      durations[status] ||= 0
      durations[status] += log.duration if log.duration
    end

    durations
  end

  # เพิ่ม method สำหรับดูระยะเวลารวมทั้งหมด
  def total_duration
    first_log = self.status_logs.order(created_at: :asc).first
    return 0 unless first_log

    (Time.now - first_log.created_at).to_i
  end

  # เพิ่ม method สำหรับดูประวัติการเปลี่ยนสถานะ
  def status_timeline
    self.status_logs.order(created_at: :desc).map do |log|
      {
        from: log.previous_status,
        to: log.new_status,
        duration: log.duration,
        changed_at: log.created_at,
        changed_by: log.created_user&.name,
        note: log.note
      }
    end
  end
end

class Product < GXTModel
  include Mongoid::Document
  include Mongoid::Timestamps

  # ความสัมพันธ์
  belongs_to :product_group, class_name: 'EsmMiotMonitor::ProductGroup'
  has_many :order_items, class_name: 'EsmMiotMonitor::OrderItem'

  # ฟิลด์
  key :product_group_id, ObjectId
  key :code, String        # รหัสสินค้า
  key :name, String        # ชื่อสินค้า
  key :generic_name, String # ชื่อสามัญ
  key :description, String # รายละเอียด
  key :unit, String       # หน่วยพื้นฐาน
  key :dosage_form, String # รูปแบบยา
  key :concentration, String # ความเข้มข้น
  key :active, Boolean    # สถานะการใช้งาน
  
  # Validations
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :unit, presence: true
end

class ProductGroup < GXTModel
  include Mongoid::Document
  include Mongoid::Timestamps

  # ความสัมพันธ์
  has_many :products, class_name: 'EsmMiotMonitor::Product'
  
  # ฟิลด์
  key :code, String      # รหัสกลุ่ม
  key :name, String      # ชื่อกลุ่ม
  key :description, String # รายละเอียด
  key :active, Boolean   # สถานะการใช้งาน
  key :sort_order, Integer # ลำดับการแสดงผล
  
  # Validations
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end

# Controllers
class OrderController < GXTDocument
end

class OrderItemController < GXTDocument  
end

class ProductController < GXTDocument
end

class ProductGroupController < GXTDocument
end

# เพิ่มโมเดล OrderItemStatusLog
class OrderItemStatusLog < GXTModel
  include Mongoid::Document
  include Mongoid::Timestamps

  # ความสัมพันธ์
  belongs_to :order_item, class_name: 'EsmMiotMonitor::OrderItem'
  belongs_to :created_user, class_name: 'EsmMiotMonitor::User'

  # ฟิลด์
  key :order_item_id, ObjectId
  key :created_user_id, ObjectId
  key :previous_status, String
  key :new_status, String
  key :duration, Integer  # เก็บระยะเวลาเป็นวินาที
  key :note, String

  # Validations
  validates :order_item_id, presence: true
  validates :new_status, presence: true

  # Callbacks
  before_create :calculate_duration

  private

  def calculate_duration
    return unless self.previous_status

    # หาล็อกก่อนหน้า
    previous_log = OrderItemStatusLog.where(
      order_item_id: self.order_item_id,
      new_status: self.previous_status
    ).order(created_at: :desc).first

    if previous_log
      self.duration = (self.created_at - previous_log.created_at).to_i
    end
  end
end

# เพิ่ม Controller สำหรับจัดการ logs
class OrderItemStatusLogController < GXTDocument

end

end