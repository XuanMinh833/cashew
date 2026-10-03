## I. TỔNG QUAN VỀ KIẾN TRÚC (OVERVIEW)

Ứng dụng được xây dựng dựa trên nguyên lý **Clean Architecture** của Robert C. Martin (Uncle Bob). Mục tiêu chính của kiến trúc này là phân tách ứng dụng thành các lớp (Layers) độc lập với nhau, giúp mã nguồn:
1. **Dễ bảo trì và mở rộng:** Mọi sự thay đổi về giao diện (UI) hoặc cơ sở dữ liệu (Database) không ảnh hưởng đến quy tắc nghiệp vụ (Business Rules).
2. **Độc lập nền tảng:** Lớp nghiệp vụ không phụ thuộc vào bất kỳ thư viện bên ngoài hay giao diện người dùng nào.
3. **Dễ kiểm thử (Testability):** Có thể viết Unit Test cho logic nghiệp vụ mà không cần chạy giao diện hay kết nối CSDL thật.

---

## II. SƠ ĐỒ CẤU TRÚC VÀ LUỒNG PHỤ THUỘC (ARCHITECTURAL DIAGRAM)

Nguyên tắc cốt lõi của Clean Architecture là **Dependency Rule (Nguyên tắc hướng vào trong)**: *Các lớp bên ngoài chỉ được phép phụ thuộc vào các lớp bên trong, lớp Domain nằm ở trung tâm và hoàn toàn độc lập.*

```text
+-----------------------------------------------------------------------+
|                         PRESENTATION LAYER                            |
|  - CashewDocumentApp (MaterialApp)                                    |
|  - DocumentListScreen (StatefulWidget)                                |
|  - UI Widgets (ChoiceChip, TextField, Dialog, ListView)               |
+-----------------------------------++----------------------------------+
                                    || (Gọi UseCase)
                                    \/
+-----------------------------------------------------------------------+
|                           DOMAIN LAYER                                |
|  - DocumentEntity (Mô hình dữ liệu cốt lõi)                           |
|  - Use Cases: GetDocumentsUseCase, AddDocumentUseCase,                |
|               DeleteDocumentUseCase                                   |
|  - DocumentRepository (Abstract Interface)                            |
+-----------------------------------^^----------------------------------+
                                    || (Triển khai Interface)
                                    ||
+-----------------------------------------------------------------------+
|                            DATA LAYER                                 |
|  - DocumentRepositoryImpl (Hiện thực hóa DocumentRepository)         |
|  - DocumentLocalDataSource (Bộ lưu trữ dữ liệu RAM / In-Memory)       |
+-----------------------------------------------------------------------+