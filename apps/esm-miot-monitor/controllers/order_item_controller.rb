class OrderItemController < GXTDocument
  def update_status
    begin
      item = OrderItem.find(params[:id])
      item.status = params[:status]
      item.updated_at = Time.now
      
      if item.save
        return { success: true, updated_at: item.updated_at }.to_json
      else
        return { success: false, error: 'Could not save status' }.to_json
      end
    rescue => e
      return { success: false, error: e.message }.to_json
    end
  end
end 