# AGENTS.md - Hotel Management System Coding Guide

This file is a condensed implementation guide generated from `SRS Document (4).docx`. Read it before changing code so the implementation stays aligned with the Hotel Management System SRS.

## 1. Project Overview

The Hotel Management System (HMS) is a web-based system for hotel operation management. It supports public hotel browsing, room search, customer booking, online payment, front-desk operations, housekeeping work, service and maintenance requests, invoice/financial handling, reporting, and admin account/permission management.

Main external or user-facing actors: Guest, Customer, Receptionist, Housekeeping, Hotel Manager, Admin, Payment Gateway/Bank System, and Email/OTP Service.

## 2. Global Agent Rules

- Follow the SRS behavior first. Do not invent new business flow unless the current task explicitly asks for it.
- Keep existing project architecture and naming style. Do not introduce a new framework or large refactor unless requested.
- When adding a feature, update all required layers consistently: route/view, controller, service/business logic, repository/DAO, model/DTO, validation, and tests if the project has tests.
- For list screens, implement search/filter/sort/paging where the SRS says the data may grow.
- Use server-side validation even when client-side validation already exists.
- Return user-friendly messages. Do not expose stack traces or raw database errors in UI/API responses.
- Protect every role-based endpoint on the server. Frontend menu visibility is not security.
- Avoid physical deletes for historical business data. Prefer status fields such as Active, Inactive, Disabled, Cancelled, or Deleted when the record is referenced.
- Before coding, identify the use case ID, primary actor, preconditions, normal flow, alternative flows, exceptions, and postconditions.

## 3. Actors and Responsibilities

| Actor | Responsibility |
|---|---|
| Administrator | Manages the entire system, creates/edits/deletes or locks accounts, assigns internal user permissions, and manages services, policies, and master data. |
| Hotel Manager | Monitors hotel operations, manages staff, approves room rates, manages services, and reviews revenue reports, booking statuses, occupancy rates, and operational efficiency. |
| Receptionist | Handles bookings, assists with check-in/check-out, updates guest information, assigns rooms, processes booking changes/cancellations, and generates initial invoices. |
| Housekeeping | Views the list of rooms needing cleaning; updates room statuses (e.g., dirty, clean, or under maintenance); reports room damages/incidents; replenishes amenities (such as towels, toilet paper, drinking water, room supplies, and cleaning items); and monitors inventory to report replenishment needs to the Hotel Manager when necessary. |
| Customer | Accesses the hotel's landing page, views information, searches for room types/services, and submits booking requests. Be able to view all current and past bookings. |
| Guest | Accesses the hotel's landing page, views information, and searches for room types. |

## 4. Role-Based Access Map

Implement these permissions with backend authorization checks and frontend menu visibility.

### Guest
View Home Page, Register Customer Account, Authenticate User, Reset Password, View Room Types, View Room Type Detail, Search Available Rooms.

### Customer
Authenticate User, Reset Password, Change Password, View Personal Profile, Edit Personal Profile, View Room Types, View Room Type Detail, Search Available Rooms, Create Booking, Create Multi-room Booking, View Booking History, Add Special Request, Request Booking Change, Request Stay Extension, Make Online Payment, View Payment History, Settle Checkout Payment, View Available Service, Submit Service Request, View Service Request History, Submit Maintenance Request, Submit Feedback.

### Receptionist
Authenticate User, Change Password, View Personal Profile, View Booking Requests, Process Booking Request, Change Booking Requests, View Room Map, Assign Room, Check In Customer, Create Walk-in Booking, Check Out Customer, Record Payment, Process Stay Extension Request, View Service Requests, Add Booking Service.

### Housekeeping
Authenticate User, Change Password, View Personal Profile, View Room Status Tasks, Report Room Issue, Update Room Status, Handle Maintenance Request.

### Hotel Manager
Authenticate User, Change Password, View Personal Profile, View Room Types List, Add Room Type, Edit Room Type, View Room List, Add Room, Edit Room, View Services List, Add Service, Edit Service, View Invoices, Review Invoice Detail, View Manager Dashboard, Monitor Room Issue Requests, Track Staff Work, Manage Promotions, Manage Refunds and Surcharges.

### Admin
Authenticate User, Change Password, View System Dashboard, View Customer Accounts, Change Customer Accounts Status, Create Staff Accounts, Edit Staff Accounts, Change Staff Accounts Status, Change Roles and Permissions, Manage Hotel Information.

## 5. Modules and Use Cases

Use case names follow Verb + Object style. Keep names consistent with the SRS in code comments, route labels, menu labels, and test names.

### Authentication & Account Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-01 | Authenticate User | Users log in to the system so that they can access functions allowed for their assigned role. |
| UC-02 | Register Customer Account | Guest creates a customer account to make bookings and track booking information. |
| UC-26 | Reset Password | User resets account password through a valid verification process. |
| UC-29 | Change Password | User changes the current password after successful authentication. |

### Booking Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-04 | Create Booking | Customer creates a room booking for a selected stay period and stores booking information in the system. |
| UC-05 | Create Multi-room Booking | Customer books multiple rooms in one booking for a group stay. |
| UC-07 | Request Booking Change | Customer requests changes to booking information such as stay dates, room type, guest count, or note. |
| UC-08 | Request Stay Extension | Customer requests to extend an active stay if the room is available for the extended period. |
| UC-32 | View Booking History | Customer views current and past booking records. |
| UC-33 | Add Special Request | Customer can ask for extra request(s) before booking. |

### Customer Profile Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-27 | View Personal Profile | User can view personal profile information such as name, phone number, email, or address. |
| UC-28 | Edit Personal Profile | User can edit personal profile information in need of updating wrong/outdated informations |

### Feedback Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-36 | Submit Feedback | Customer submits rating and feedback about hotel rooms, services, or stay experience. |

### Front Desk Operations
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-12 | Process Booking Request | Receptionist reviews, confirms, updates, or rejects customer booking requests. |
| UC-13 | Assign Room | Receptionist assigns a specific available room to a confirmed booking. |
| UC-14 | Check In Customer | Receptionist verifies customer and booking information, starts the stay, and updates room status to occupied. |
| UC-15 | Create Walk-in Booking | Receptionist creates a booking for a guest without prior reservation when rooms are available. |
| UC-16 | Check Out Customer | Receptionist confirms final charges, completes checkout, updates booking status, and sends the room to cleaning. |
| UC-37 | Change Booking Requests | Receptionist update/edit booking records to reflect the most accurate and current customer needs. |
| UC-40 | Process Stay Extension Request | Receptionist reviews and processes customer stay extension requests. |

### Hotel Information Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-25 | View Home Page | Guest or customer views hotel introduction, room highlights, contact information, and public content. |
| UC-51 | Manage Hotel Information | Admin updates hotel description, images, contact details, and public information shown on the website. |

### Hotel Operation Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-47 | Track Staff Work | Hotel Manager tracks staff work, task progress, and operational responsibilities. |

### Hotel Service Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-09 | View Available Service | Customer views the list of available hotel services with service name, description, unit price so that they can choose a suitable service during their stay. |
| UC-17 | View Booking Requests | Receptionist views the list of service requests submitted by checked-in customers and accepts or cancels each request to keep request statuses updated correctly. |
| UC-18 | Add Booking Service | Receptionist manually adds hotel services to a customer's booking at the front desk based on the customer's direct request so that the service is provided and included in the invoice. |
| UC-61 | View Services List | Hotel Manager views, searches, filters, enables, disables, and deletes hotel service records. |
| UC-62 | Add Service | Hotel Manager creates a new hotel service with service name, description, unit price, and unit. |
| UC-63 | Edit Service | Hotel Manager updates existing service information, including service name, description, unit price, and unit of measure. |

### Housekeeping Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-19 | Update Room Status | Housekeeping staff updates room status such as Cleaned, Uncleaned, or Needs Issue Handling so receptionists know which rooms are ready or unavailable. |
| UC-41 | View Room Status Tasks | Housekeeping staff views rooms that need cleaning or status checking so room operations can be prioritized. |
| UC-42 | Report Room Issue | Housekeeping staff reports room damage, missing items, or issues found during cleaning. |

### Invoice & Financial Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-20 | Manage Refunds and Surcharges | Hotel Manager creates and controls refund or surcharge records for invoices and exceptional adjustments. |
| UC-43 | View Invoices | Hotel Manager views invoice list and invoice payment status for management checking. |
| UC-44 | Review Invoice Detail | Hotel Manager reviews detailed invoice information, including room charges, service charges, discounts, and surcharges. |

### Maintenance Request Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-53 | Submit Maintenance Request | Customer submits a room maintenance request for issues such as broken equipment, water leakage, air conditioner problems, lighting problems, or missing room items during the stay. |
| UC-54 | Handle Maintenance Request | Housekeeping staff receives and updates customer maintenance-related room requests so room problems can be tracked and resolved. |

### Payment Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-06 | Make Online Payment | Customer pays for a booking or invoice through an online payment gateway. |
| UC-11 | Settle Checkout Payment | Customer pays the remaining checkout balance before completing the checkout process. |
| UC-34 | View Payment History | Customer views online payment records and payment status history. |
| UC-39 | Record Payment | Receptionist records payment made at the front desk or confirms payment information for a booking. |

### Promotion Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-48 | Manage Promotions | Hotel Manager creates and updates promotions or discount campaigns for customers. |

### Report & Dashboard Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-45 | View Manager Dashboard | Hotel Manager views revenue reports, occupancy statistic to evaluate business performance. |
| UC-52 | View System Dashboard | Admin views summarized system statistics, operational indicators, and management dashboard information. |

### Room Browsing
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-03 | Search Available Rooms | Guest or customer searches available rooms by stay dates, number of guests, and room criteria. |
| UC-30 | View Room Types | Guest or customer views available room type information, including price, capacity, amenities, and images. |
| UC-31 | View Room Type Detail | Guest or customer views detailed information of a selected room type before booking. |

### Room Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-38 | View Room Map | Receptionist views the visual room map and room status for operation tracking. |
| UC-55 | View Room Types List | Hotel Manager views, searches, filters, and deletes room type records from the room type list. |
| UC-56 | Add Room Type | Hotel Manager creates a new room type with name, base price, capacity, bed type, area, image URL, description, and amenities. |
| UC-57 | Edit Room Type | Hotel Manager updates existing room type information such as price, capacity, bed type, image, description, and amenities. |
| UC-58 | View Room List | Hotel Manager views, searches, filters, and deletes physical room records such as room number, floor, room type, status, and listed price. |
| UC-59 | Add Room | Hotel Manager creates a new room record with room number, floor, room type, and initial status. |
| UC-60 | Edit Room | Hotel Manager updates room information such as room number, floor, room type, and room status. |

### Service Request Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-10 | Submit Service Request | Customer submits a request so hotel staff can support issues during the stay. |
| UC-35 | View Service Requests | Receptionist views the list of service requests submitted by checked-in customers, reviews request details, and updates the request status by Pending , completed, or canceled the request so that customer service needs are handled properly. |
| UC-46 | Monitor Room Issue Requests | Hotel Manager monitors customer service requests and their handling progress. |
| UC-64 | View Service Request History | Customer views the history of submitted service requests with request type, description, created date, and current status so that they can track whether each request is pending,completed, or cancelled. |

### User & Permission Management
| UC ID | Use Case | Coding meaning |
|---|---|---|
| UC-21 | Create Staff Accounts | Admin creates a new staff account with specific personal information and role assignments. |
| UC-22 | Edit Staff Accounts | Admin updates existing staff information, such as contact details or roles. |
| UC-23 | Change Staff Accounts Status | Admin temporarily disables (locks) or reactivates (unlocks) a staff account's access to the system. |
| UC-24 | Change Roles and Permissions | Admin configures role permissions so each actor can access only allowed functions. |
| UC-49 | View Customer Accounts | Admin can monitors customer account status for registered user profiles. |
| UC-50 | Change Customer Accounts Status | Admin temporarily disables (locks) or reactivates (unlocks) customer registered account's access to the system. |

## 6. Core Workflows to Preserve

### 6.1 Public and Account Flow
- Guest can view public hotel information, room types, room type details, and search available rooms without login.
- Guest can register a customer account.
- Users can authenticate, reset password, change password, and view/edit their own profile according to role.
- Passwords must be stored with one-way hashing, preferably BCrypt, and never displayed.
- Email is the unique login identifier and should not be changed after registration.

### 6.2 Customer Booking Flow
- Customer searches available rooms by dates, guest count, and room criteria.
- Customer selects room type/details and creates single-room or multi-room booking.
- Validate check-out date is after check-in date, guest count does not exceed capacity, and selected room/room type is available.
- Store booking with status such as Pending or Confirmed according to payment/approval policy.
- Booking history must show current and past bookings owned by the customer only.
- Booking change can be requested only by the booking owner while booking is Pending or Confirmed, before check-in.
- Stay extension can be requested only for a CheckedIn stay, with a later checkout date and no overlap with another confirmed booking.

### 6.3 Payment and Invoice Flow
- Online payment sends request to VNPay/Bank Payment Gateway and receives redirect result plus callback/IPN.
- Verify transaction information before updating booking, invoice, or payment status.
- Store every transaction result: success, failed, cancelled, refunded, reconciled, or pending.
- Booking deposit is 30 percent of room charge.
- Invoice total equals line items: room charge, services, surcharges, discounts/refunds according to financial rules.
- Paid invoice cannot receive new surcharge or refund request.
- Record payment at front desk must create/adjust invoice/payment history and audit log.

### 6.4 Receptionist Front-Desk Flow
- Receptionist views booking requests, processes booking requests, changes booking requests, assigns rooms, checks in customers, creates walk-in bookings, checks out customers, records payments, and processes stay extension requests.
- Assign Room must select only available/ready/clean rooms and prevent overlap with active bookings.
- Check In Customer requires verified customer/booking information and a valid assigned room; update booking to CheckedIn and room to Occupied.
- Check Out Customer reviews final charges, service charges, surcharges, discounts, and payment status; update booking to CheckedOut and room to Cleaning or Maintenance as needed.
- After checkout, create/trigger housekeeping cleaning task.

### 6.5 Customer Service Request Flow
- Customer can view available active services before creating a request.
- Submit Service Request requires an active booking/room and selected service type.
- View Service Request History displays booking room, service type, submitted time, status, and actions such as cancel pending request or view cancellation reason.
- Receptionist can view service requests submitted by checked-in customers, search/filter them, approve/provide, reject/cancel, and view detail.
- Receptionist can Add Booking Service directly to a booking only when booking is not fully closed and service is active; invoice amount must be recalculated.
- Disabled services must not appear in the customer service list or add-booking-service selector.

### 6.6 Maintenance and Housekeeping Flow
- Customer can submit maintenance request for room issues such as broken equipment, water leakage, air conditioner problems, lighting problems, or missing room items during stay.
- Housekeeping views room status tasks, reports room issues, updates room status, and handles maintenance requests.
- Housekeeping can mark a room Available only after cleaning is completed and no unresolved room issue remains.
- Customer/room issue request can be assigned only to active Housekeeping staff. Assigning a Pending request automatically moves it to In-progress.
- A request cannot be Completed unless assigned staff exists; completion time must be recorded for staff productivity tracking.

### 6.7 Manager Flow
- Hotel Manager manages room types, rooms, hotel services, promotions, invoices, refunds, surcharges, reports, customer requests, and staff work tracking.
- Room type CRUD must validate required fields: name, capacity, bed type, base price, area, image/description/amenities as applicable.
- Room CRUD must keep room number unique and ensure each room belongs to an existing room type.
- Hotel service CRUD must require service name, unit price, unit of measure, and active/disabled status.
- Revenue and occupancy reports count only Confirmed, CheckedIn, or CheckedOut bookings and exclude Pending, Rejected, Cancelled.
- Manager dashboard/report screens are read-only.

### 6.8 Admin Flow
- Admin manages staff accounts, customer accounts, roles and permissions, hotel information, and system dashboard.
- Admin can lock/unlock customer and staff accounts; locked/inactive users cannot log in.
- Role and permission changes must be audited and applied to backend authorization.
- Hotel information updates affect public website content.

## 7. Data Model Reference

Use existing database naming if the project already has schema. Do not rename tables/fields casually. These are the SRS entities and their meanings.

| Entity | Purpose |
|---|---|
| Role | Stores system roles used for authorization, such as Admin, Hotel Manager, Receptionist, Housekeeping, Customer, and Guest-related access. |
| Account | Stores essential login credentials, profile details, operational system logs, and availability statuses for all registered staff members and general system users. |
| Customer | Acts as a specialized extension of the Account entity, dedicated to holding tailored hotel client profiles, loyalty system points, and structural membership tiers. |
| Feedback | Stores customer reviews, feedback comments, ratings, and creation timestamps regarding the hotel's services. |
| Task | Stores specific tasks assigned to hotel staff members, including descriptions and assignment/update timestamps. |
| CustomerRequest | Stores service or support requests made by customers, linked to a specific room, booking, priority level, and assignment status. |
| RoomType | Defines the core configurations, baseline night/hourly pricing structures, capacity thresholds, physical room dimensions, and bed setups for various hotel room tiers. |
| Room | Represents individual physical room instances within the hotel property, tracking their specific floor locations, categories, and real-time operational or housekeeping statuses. |
| RoomImage | Manages the rich media library, managing image URLs and digital photography paths used to visually showcase specific room types on user interfaces. |
| Amenity | Functions as the master directory for hotel facilities, in-room appliances, and specialized utilities (e.g., Wi-Fi, AC, Minibar) along with their graphic representation icons. |
| RoomAssignment | Stores actual physical room assignment information for a specific booking, including the staff member who assigned it. |
| Booking | Records reservation workflows, capturing schedule blocks, reservation state machines, total costs, specific customer requests, and guest metrics for room rentals. |
| BookingChangeRequest | Stores requests from customers to modify their booking details (such as dates, room types, or room quantities) along with any additional charges. |
| ServiceOrder | Stores service orders placed by customers, acting as a bridge between the customer's account and the specific service ordered. |
| HotelService | A catalog of services provided by the hotel (e.g., Laundry, Spa, Restaurant, Room Service) including pricing, unit, and active status. |
| CheckIn | Stores actual check-in records, capturing the arrival time, handling receptionist, and any special requests upon check-in. |
| CheckInCompanion | Stores information about accompanying guests (companions staying in the same room) alongside the primary guest during check-in. |
| Invoice | Documents financial ledger closures at checkout, mapping financial settlement states to explicit bookings while tracking overall customer billing milestones. |
| InvoiceItem | Breaks down the invoice into individual transactional rows, detailing granular charges for room nights alongside additional point-of-sale services (e.g., Laundry, Mini-bar consumption). |
| Refund | Registers transaction rollbacks and financial compensations, tracking authorized payout figures, timestamps, and formal justifications for booking cancellations or modifications. |
| RoomType_Amenity | A junction table resolving the Many-to-Many relationship between RoomType and Amenity, defining which amenities are available for each room type. |

## 8. Important Status Values and Transitions

- Account: Active, Inactive/Locked. Locked or inactive accounts cannot authenticate.
- Booking: Pending, Confirmed, Rejected, Cancelled, CheckedIn, CheckedOut. Booking change allowed only before check-in while Pending or Confirmed.
- Room: Available/Ready/Clean, Occupied, Cleaning/Dirty, Under Maintenance/Unavailable. Assign only Available/Ready/Clean rooms.
- Invoice: Pending, Paid, Refunding. The SRS says the system does not use a separate Refunded status; confirming all pending refunds returns invoice to Pending.
- Payment transaction: Pending, Success/Paid, Failed, Cancelled, Refunded/Reconciled as applicable. Always store gateway transaction reference.
- Service/Maintenance request: Pending, In-progress/Accepted/Provided, Completed, Cancelled. Do not complete unassigned requests.
- Hotel service: Active, Disabled. Disabled services are hidden from new customer orders and cannot be added to bookings.

## 9. Business Rules

The rules below are implementation constraints. Enforce them in services/domain logic, not only in UI.

- BR-01: Guests can view public hotel information, room types, room type details, and search available rooms without logging in.
- BR-02: Only registered customers can create bookings, view booking history/status, request booking changes, make online payments, submit service requests, and submit feedback.
- BR-03: Each account must have one active role, and users can access only the screens and functions allowed for that role.
- BR-04: A booking can be created only when the selected stay dates are valid and at least one suitable room or room type is available.
- BR-05: Check-out date must be later than check-in date; the system must not accept an invalid stay period.
- BR-06: The number of guests in a booking must not exceed the capacity of the selected room type or selected rooms.
- BR-07: A room cannot be assigned to more than one active booking for the same date range.
- BR-08: Only rooms with a suitable operational status, such as Available or Ready/Clean, can be assigned for check-in.
- BR-09: A booking can be checked in only after customer information is verified and a valid room has been assigned.
- BR-10: A booking can be checked out only after final room charges, service charges, surcharges, discounts, and payment status are reviewed.
- BR-11: When checkout is completed, the related room must be changed to Cleaning or another appropriate unavailable status before it can be sold again.
- BR-12: Online payments must be verified through the payment gateway result before the system updates a booking or invoice as Paid.
- BR-13: All payment transactions, including failed, cancelled, refunded, or reconciled payments, must be stored for payment history and manager review.
- BR-14: Refunds and surcharges must include a reason and can be created or approved only by authorized management roles.
- BR-15: Hotel services can be added to a booking only when the service is active and the booking has not been fully closed.
- BR-16: Housekeeping can mark a room as Available only when cleaning is completed and no unresolved room issue is recorded.
- BR-17: Supply quantity must not become negative; low-stock items must be shown in the low supply report when they fall below the defined threshold.
- BR-18: Promotions must have a valid effective date range and can be applied only when the booking satisfies the promotion conditions.
- BR-19: Refund Amount cannot exceed invoice total price
- BR-20: Hotel Manager can manage room types, rooms, and hotel services only after successful authentication and authorization.
- BR-21: Deleted room types, rooms, or services should use logical deletion or disabled status when they are already linked to bookings, invoices, service orders, or historical records.
- BR-22: Room type information must include valid required fields such as room type name, capacity, bed type, base price, area, and related amenities.
- BR-23: A room type linked to existing rooms or booking history should not be physically deleted; it should be disabled or hidden when needed.
- BR-24: Room type base price must be greater than 0.
- BR-25: Room type capacity and area must be positive values.
- BR-26: Updating a room type must not break existing room records, booking records, invoice history, or historical price information.
- BR-27: Each physical room number must be unique in the hotel.
- BR-28: A room linked to an active booking or current stay cannot be deleted.
- BR-29: Room status must follow the allowed room status values and valid status transition rules.
- BR-30: Each room must belong to an existing room type.
- BR-31: Changing a room type or room status must not conflict with active bookings, current stays, cleaning tasks, or unresolved maintenance issues.
- BR-32: Service name, unit price, and unit of measure are required for each hotel service.
- BR-33: A disabled hotel service must not be available for new customer orders.
- BR-34: A service linked to invoices or service orders should not be physically deleted; it should be disabled to preserve historical records.
- BR-35: A user can view and update only their own profile and account information; access to another user's profile is not allowed.
- BR-36: Each account email is unique and is used as the login identifier; the email cannot be changed after registration.
- BR-37: Passwords are stored using one-way hashing (BCrypt) and are never displayed; changing a password requires the correct current password and a matching new-password confirmation.
- BR-38: A booking change can be requested only by the booking owner and only while the booking has not been checked in (status Pending or Confirmed).
- BR-39: A booking change takes effect only after it is approved by an authorized staff role; room price and deposit are recalculated on approval, and the original booking remains unchanged until then.
- BR-40: A stay extension can be requested only by the current guest of a stay whose status is CheckedIn.
- BR-41: A stay extension's new check-out date must be later than the current check-out date and must not overlap another confirmed booking of the same room.
- BR-42: A stay extension is subject to room availability; the additional nights are charged at the applicable room rate and added to the invoice once the extension is approved.
- BR-43: Management and admin dashboards are read-only; they display aggregated data and must not create, update, or delete any record.
- BR-44: The invoice list is displayed newest-first by created date and supports keyword search (invoice code, customer name, room number), status filtering and server-side paging.
- BR-45: An invoice total equals the sum of all its line items (room charge, services and surcharges).
- BR-46: Invoice summary KPIs are defined as: Total unpaid = sum of totals of invoices with status Pending; Total pending-refund = sum of totals of invoices with status Refunding.
- BR-47: A booking deposit equals 30% of the room charge; an invoice's net (collectible) amount = Total - Deposit - Refunded and must never be negative.
- BR-48: A Paid invoice cannot have new surcharges or refund requests added.
- BR-49: A surcharge unit price and a refund amount must be greater than 1; a refund amount must not exceed the refundable amount (Total - Deposit - Refunded - already-Pending).
- BR-50: Creating a refund request sets the invoice to 'Refunding'; confirming all pending refunds returns it to 'Pending'. The system does not use a separate 'Refunded' status, and refund confirmation is performed atomically (database transaction).
- BR-51: Revenue and occupancy reports count only bookings with status Confirmed, CheckedIn or CheckedOut (Pending, Rejected and Cancelled are excluded), attributed by check-in date.
- BR-52: The revenue & occupancy report defaults to the last 30 days; if the start date is after the end date they are swapped, and invalid or empty dates fall back to the default period.
- BR-53: Daily occupancy = occupied rooms / total rooms (capped at 100%); average occupancy is the average of daily values; rooms checked-in / checked-out equal the sum of room quantities of recognized bookings whose check-in / check-out date falls in the period.
- BR-54: A customer/room-issue request can be assigned only to Housekeeping staff whose work status is 'Active'; assigning a 'Pending' request automatically changes its status to 'In-progress'.
- BR-55: A request cannot be marked 'Completed' unless it has an assigned staff (validated on both client and server); completing a request records its completion time, used for staff productivity counts.
- BR-56: Request and staff-task lists are displayed newest-first and support searching, filtering and paging (requests by room/priority/assigned staff/status; a staff's assigned-task list is paged at 5 items per page).
- BR-57: Staff work tracking covers only active Housekeeping accounts; 'completed today / this month' are derived from request completion times, and 'tasks in progress' equals the number of assigned requests with status In-progress.

## 10. External Interfaces

| Interface | Actor/System | Requirement |
|---|---|---|
| User Interface | Guest, Customer, Receptionist, Housekeeping, Hotel Manager, Admin | The system shall provide a web-based user interface accessible through common desktop and mobile browsers. Public pages shall be available to guests, while protected dashboards shall be shown only after login according to user role. |
| Role-Based Workspace Interface | Internal users and Customer | After successful login, the system shall redirect users to the correct workspace, such as Customer Portal, Receptionist workspace, Housekeeping workspace, Hotel Manager workspace, or Admin workspace. |
| Payment Gateway Interface | VNPay / Bank Payment System | The system shall send payment requests to the payment gateway and receive payment results through redirect response and IPN/callback. The system shall verify transaction information before updating booking, invoice, and payment status. |
| Email / OTP Notification Interface | Email/SMTP or OTP Service | The system shall support sending OTP codes, password reset instructions, booking confirmations, payment results, and important operation notifications through an email or OTP service. |
| Database Interface | HMS Database | The system shall store and retrieve hotel data, including accounts, customers, staff, rooms, bookings, invoices, payments, services, housekeeping tasks, room issues, supplies, promotions, policies, and reports. |
| Error and Message Interface | All users | The system shall display clear validation messages, permission messages, payment failure messages, and unexpected error messages without exposing technical details to end users. |

## 11. Non-Functional Requirements

### Usability
- US-01 - Role-based navigation: After login, each user shall see only the menus and functions allowed for their role to reduce confusion and prevent incorrect operations.
- US-02 - Basic training time: A normal user such as Customer or Housekeeping should be able to perform common tasks after no more than 30 minutes of training. Internal staff such as Receptionist or Hotel Manager should be able to perform assigned daily operations after no more than 2 hours of training.
- US-03 - Common task efficiency: Common tasks should be completed within a reasonable number of steps: room search within 3 steps, booking creation within 5 major steps, check-in within 5 major steps, and cleaning status update within 3 major steps.
- US-04 - Form validation guidance: The system shall show field-level validation messages for required fields, invalid date ranges, invalid email/phone formats, exceeded room capacity, and unavailable rooms.
- US-05 - Consistent UI behavior: Buttons, filters, search fields, status labels, and confirmation dialogs shall follow a consistent layout and wording across major screens.
- US-06 - Responsive access: Public pages and customer booking/payment pages should be usable on common laptop and mobile screen sizes.

### Performance
- PER-01 - Page response time: Public pages, login page, profile page, and common list pages should load within 3 seconds under normal network and server conditions.
- PER-02 - Room search response: Room availability search should return results within 5 seconds for normal search criteria because it directly affects Guest and Customer booking decisions.
- PER-03 - Booking transaction: Create Booking, Create Multi-room Booking, Assign Room, Check In Customer, and Check Out Customer should complete within 5 seconds after submission if no external service is involved.
- PER-04 - Payment processing: For online payment, the system should create the payment request within 5 seconds. Final payment status update depends on the payment gateway response and callback.
- PER-05 - Report generation: Revenue Report, Occupancy Report, Invoice List, and Low Supply Report should display within 10 seconds for normal date ranges. Large reports may use paging, filtering, or pre-aggregated data.
- PER-06 - Concurrent users: The system should support at least 50 concurrent users for small hotel operation, including public visitors, customers, and internal staff.
- PER-07 - List handling: Major list screens such as bookings, rooms, customers, invoices, payments, staff accounts, service requests, and reports shall support paging to avoid slow loading when data grows.

### Maintainability
- MAIN-01 - Modular design: The system should separate major modules such as authentication, booking, room management, payment, housekeeping, service requests, reporting, and administration.
- MAIN-02 - Configuration data: Statuses, payment methods, service categories, request categories, room types, and policy settings should be configurable by authorized users where practical instead of being hard-coded.
- MAIN-03 - Readable code and naming: Source code, database objects, and screen/function names should use consistent naming that reflects the HMS business domain.
- MAIN-04 - Change support: The system should allow future updates such as adding new room types, services, promotions, report filters, or payment methods with minimal impact on unrelated modules.
- MAIN-05 - Error logging: Unexpected errors should be logged with enough information for developers or administrators to investigate without showing technical stack traces to end users.

## 12. Other System Requirements

- OR-01 - Audit Log: The system should record important actions such as login, logout, account changes, booking updates, room assignment, check-in, check-out, payment updates, refund/surcharge approval, permission changes, and hotel information changes.
- OR-02 - Data Ownership: Customers must view and update only their own booking, payment history, service request, feedback, and profile information.
- OR-03 - Role-Based Navigation: After login, users should be redirected to the correct dashboard or workspace based on their role.
- OR-04 - Session Timeout: The system should automatically expire inactive sessions according to the configured security policy.
- OR-05 - Date and Time Standard: All booking, payment, invoice, cleaning, and report timestamps should be stored consistently and displayed in local hotel time.
- OR-06 - Booking Code: Each booking should have a unique booking code so receptionists and customers can search or track booking information.
- OR-07 - Invoice Number: Each invoice should have a unique invoice number for payment tracking, reporting, and reconciliation.
- OR-08 - Transaction Reference: Each online payment transaction should store gateway transaction reference, amount, status, payment method, and response time.
- OR-09 - Soft Delete Preference: Important business records such as accounts, bookings, invoices, payments, and room records should be disabled or marked inactive instead of being physically deleted where audit is required.
- OR-10 - Search and Filter: Major list screens should support searching, filtering, sorting, and paging where the data volume may grow, such as bookings, rooms, customers, invoices, payments, staff accounts, and reports.
- OR-11 - Validation Consistency: Required fields, date ranges, email format, phone format, price values, quantities, and status changes must be validated on both user interface and server side.
- OR-12 - Notification Events: The system should send or display notifications for booking confirmation/rejection, payment result, password reset, service request status, and important operation updates where applicable.
- OR-13 - Report Export: Management reports such as revenue report, occupancy report, invoice list, and low supply report should be exportable if required by the implementation scope.
- OR-14 - Configuration Data: Statuses, room types, service categories, request categories, payment methods, and policy settings should be configurable by authorized users rather than hard-coded where practical.
- OR-15 - Error Handling: The system should display user-friendly messages for validation errors, unavailable data, payment failures, permission denial, and unexpected system errors.
- OR-16 - Payment Gateway Callback: The system should support payment gateway callback/IPN handling independently from customer browser redirect to reduce incorrect payment status.
- OR-17 - Daily Report Aggregation: The system may run scheduled jobs to aggregate revenue and occupancy data for faster dashboard and report display.
- OR-18 - Booking Lifecycle Automation: The system may run scheduled jobs to cancel overdue unpaid bookings, mark no-show bookings, and release rooms according to hotel policy.
- OR-19 - Data Backup: Database backup should be performed regularly to reduce the risk of losing booking, customer, payment, invoice, and operation data.
- OR-20 - Access Denial: If a user tries to access a function outside the assigned role, the system must deny access and display a permission message instead of showing restricted data.

## 13. Suggested Code Organization

Use this only as guidance; adapt to the existing project structure.

- auth: login, logout, register, reset password, change password, session/JWT handling, BCrypt hashing.
- account-profile: personal profile view/edit for Customer, Receptionist, Housekeeping, Manager, Admin.
- room-browsing: public room types, room type detail, available room search.
- booking: create booking, create multi-room booking, booking history, booking status, booking change request, stay extension.
- payment-invoice: online payment, gateway callback/IPN, payment history, checkout settlement, invoice list/detail, refund/surcharge.
- front-desk: booking request processing, room assignment, check-in, walk-in booking, checkout, room map, record payment.
- services: available service list, submit service request, service request history, receptionist service request processing, add booking service.
- housekeeping: room status tasks, update room status, report room issue, handle maintenance request.
- manager: room type/room/service management, promotions, dashboard, revenue/occupancy reports, staff work tracking, monitor room issue requests.
- admin: staff/customer account management, lock/unlock, roles and permissions, hotel information, system dashboard.

## 14. Implementation Checklist for Each Task

1. Identify the use case and role.
2. Check route/controller authorization.
3. Validate request data on server side.
4. Check ownership and role permission before reading or updating data.
5. Apply business rules and valid status transitions.
6. Use transaction boundaries for multi-record updates such as booking payment, check-in/check-out, refund confirmation, and room assignment.
7. Write audit log for important operations.
8. Return clear success/error messages.
9. Update list/search/filter/paging behavior if the feature appears in list screens.
10. Add or update tests if a test structure exists.

## 15. Do Not Break These Invariants

- RBAC must be enforced on both UI and server side; do not rely on hiding buttons only.
- Customers can access only their own bookings, payments, feedback, service requests, maintenance requests, and profile data.
- Use soft delete or disabled/inactive status for records linked to history: accounts, bookings, rooms, room types, services, invoices, payments.
- Validate on both client and server: required fields, date ranges, email, phone, price, quantity, status transition, role permission.
- Never update payment status to Paid until the payment gateway result/callback is verified.
- Room assignment must prevent date-range overlap with active bookings and only assign rooms in a valid clean/available status.
- A disabled hotel service must not appear as selectable for new customer orders/service requests.
- Dashboards are read-only; they must aggregate data and must not create/update/delete business records.

## 16. Quick Service Request Implementation Notes

This project often needs Service Request coding. Use these details when coding that module:

- Customer Submit Service Request screen: booking/room dropdown, service type dropdown, submit button.
- Customer View Available Service screen: service list section with service name and service description. Only active services are visible.
- Customer View Service Request History screen: request table with booking room, service type, submitted time, status, action column, pagination, search, cancel pending request, and view cancellation reason.
- Receptionist View Service Requests screen: summary cards, search box, status filters, request table, approve/provide action, reject/cancel action, detail view.
- When a request is processed, prevent duplicate processing by checking latest status before updating.
- Service request statuses in UI may appear as Pending/Provided/Cancelled or Vietnamese equivalents such as Dang cho/Da hoan tat/Da huy. Keep internal enum consistent and map labels in the UI.

## 17. Done Definition

A coded feature is done only when:

- It matches the SRS use case flow and business rules.
- It has role/ownership checks on backend.
- It validates inputs on server side.
- It uses correct statuses and does not create invalid transitions.
- It updates related records consistently, especially invoice/payment/room/booking/request records.
- It preserves history through audit logs or non-destructive status changes where required.
- It shows user-friendly messages and handles empty results, invalid input, permission denial, and system errors.
