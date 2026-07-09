package com.mycompany.hotelmanagement.entity;

/**
 * InvoiceItem
 * Dòng chi tiết hóa đơn: tiền phòng (Room), dịch vụ thêm (Service) hoặc phụ phí (Surcharge).
 *
 * Date: 02/6/2026
 * ver 1.0
 * @author Phạm Quốc Quý
 */
public class InvoiceItem {

    private int itemId;
    private int invoiceId;
    private String itemType;     // Room / Service / Surcharge
    private String description;
    private int quantity;
    private double unitPrice;
    private double amount;

    public InvoiceItem() {}

    /* ---------- Getters & Setters ---------- */
    public int getItemId()                { return itemId; }
    public void setItemId(int v)          { this.itemId = v; }

    public int getInvoiceId()             { return invoiceId; }
    public void setInvoiceId(int v)       { this.invoiceId = v; }

    public String getItemType()           { return itemType; }
    public void setItemType(String v)     { this.itemType = v; }

    public String getDescription()        { return description; }
    public void setDescription(String v)  { this.description = v; }

    public int getQuantity()              { return quantity; }
    public void setQuantity(int v)        { this.quantity = v; }

    public double getUnitPrice()          { return unitPrice; }
    public void setUnitPrice(double v)    { this.unitPrice = v; }

    public double getAmount()             { return amount; }
    public void setAmount(double v)       { this.amount = v; }
}
