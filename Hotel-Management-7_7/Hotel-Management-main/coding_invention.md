# Coding Convention for Java Agents

> Purpose: This file gives coding rules for AI agents when generating, modifying, or reviewing Java code in this project. Follow these rules to keep the code readable, maintainable, and consistent with the Oracle/Sun Java Code Conventions.

## 1. General Principles

- Prioritize readability and maintainability over clever or compressed code.
- Write code that another developer can understand quickly.
- Keep source files clean, organized, and easy to navigate.
- Avoid unnecessary complexity, long methods, long classes, and deeply nested logic.
- Do not add redundant comments that simply repeat the code.
- When code becomes hard to explain, refactor it instead of adding many comments.

## 2. Java File Naming

- Java source files must use the `.java` suffix.
- Java bytecode files use the `.class` suffix.
- A Java source file should contain one public class or interface.
- The public class or interface name must match the file name.
- Private helper classes may be placed in the same file only when they are strongly related to the public class.

Example:

```java
public class OrderService {
    // Implementation
}
```

File name:

```text
OrderService.java
```

## 3. Source File Organization

Organize Java source files in this order:

1. Beginning file comment, if required by the project.
2. Package statement.
3. Import statements.
4. Class or interface documentation comment.
5. Class or interface declaration.
6. Static variables.
7. Instance variables.
8. Constructors.
9. Methods, grouped by functionality.

Example:

```java
package service;

import model.Order;
import repository.OrderRepository;

/**
 * Provides business logic for managing customer orders.
 */
public class OrderService {
    private static final int MAX_ORDER_ITEMS = 50;

    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    public Order createOrder(Order order) {
        return orderRepository.save(order);
    }
}
```

## 4. File Size

- Avoid source files longer than 2000 lines.
- If a class becomes too long, split responsibilities into smaller classes.
- Do not create large utility classes containing unrelated methods.

## 5. Indentation and Line Length

- Use 4 spaces for indentation.
- Do not use tabs for indentation.
- Avoid lines longer than 80 characters when possible.
- For documentation examples, keep lines shorter, around 70 characters.
- When wrapping long lines:
  - Break after a comma.
  - Break before an operator.
  - Prefer breaking at a higher-level expression.
  - Align continuation lines clearly.
  - Use 8 spaces for continuation indentation when alignment becomes unclear.

Example:

```java
public void createReservation(String customerName, String roomType,
        LocalDate checkInDate, LocalDate checkOutDate) {
    // Implementation
}
```

## 6. Comments

### 6.1 Use Comments Properly

- Use comments to explain why code exists, not what obvious code does.
- Explain nontrivial logic, business rules, algorithms, or important decisions.
- Avoid comments that duplicate clear code.
- Avoid large decorative comment boxes.
- Do not leave outdated comments.

Good:

```java
// Reject duplicated callbacks to prevent double payment processing.
if (paymentRepository.existsByTransactionId(transactionId)) {
    return;
}
```

Bad:

```java
// Increase i by 1.
i++;
```

### 6.2 Documentation Comments

Use Javadoc comments for public classes, interfaces, constructors, methods, and important fields.

Example:

```java
/**
 * Calculates the final order total after discount and shipping fee.
 *
 * @param order the order being calculated
 * @return the final payable amount
 */
public BigDecimal calculateTotal(Order order) {
    // Implementation
}
```

### 6.3 Implementation Comments

Use block comments or single-line comments for implementation details.

Example:

```java
/* Validate the payment result before updating order status. */
validatePaymentResult(paymentResult);
```

### 6.4 Special Comments

- Use `FIXME` for broken logic that must be fixed.
- Use `XXX` for suspicious logic that currently works but needs review.
- Do not leave `TODO`, `FIXME`, or `XXX` without a clear reason.

Example:

```java
// FIXME: Handle payment timeout from the gateway.
```

## 7. Declarations

- Declare one variable per line.
- Do not declare different types on the same line.
- Do not declare variables and methods on the same line.
- Declare variables at the beginning of the smallest reasonable block.
- Initialize local variables where they are declared when possible.
- Avoid declaring local variables that hide fields or variables from outer scopes.

Good:

```java
int level;
int size;
String customerName;
```

Bad:

```java
int level, size;
int count;
if (condition) {
    int count;
}
```

## 8. Class and Interface Formatting

- No space between a method name and the opening parenthesis.
- Put the opening brace at the end of the declaration line.
- Put the closing brace on its own line.
- Separate methods with one blank line.
- Use blank lines to separate logical code sections.

Good:

```java
public class CustomerService {
    public Customer findById(int customerId) {
        return customerRepository.findById(customerId);
    }

    public void updateProfile(Customer customer) {
        customerRepository.update(customer);
    }
}
```

Bad:

```java
public class CustomerService
{
    public Customer findById (int customerId) { return customerRepository.findById(customerId); }
}
```

## 9. Statements

### 9.1 One Statement Per Line

Good:

```java
index++;
count--;
```

Bad:

```java
index++; count--;
```

### 9.2 Always Use Braces

Always use braces with control structures, even for one-line bodies.

Good:

```java
if (isValid) {
    saveOrder(order);
}
```

Bad:

```java
if (isValid)
    saveOrder(order);
```

### 9.3 Return Statements

- Do not use unnecessary parentheses in return statements.
- Use simple direct returns when possible.

Good:

```java
return order.isPaid();
```

Bad:

```java
if (order.isPaid()) {
    return true;
} else {
    return false;
}
```

### 9.4 If Statements

Use this format:

```java
if (condition) {
    statements;
} else if (anotherCondition) {
    statements;
} else {
    statements;
}
```

### 9.5 For Statements

Use this format:

```java
for (int i = 0; i < items.size(); i++) {
    process(items.get(i));
}
```

Avoid complex `for` statements with too many variables.

### 9.6 While Statements

Use this format:

```java
while (condition) {
    statements;
}
```

### 9.7 Do-While Statements

Use this format:

```java
do {
    statements;
} while (condition);
```

### 9.8 Switch Statements

- Every `switch` statement must include a `default` case.
- Every `case` should normally end with `break`, `return`, or `throw`.
- If fall-through is intentional, add a clear comment.

Example:

```java
switch (status) {
    case PENDING:
        processPendingOrder(order);
        break;
    case PAID:
        processPaidOrder(order);
        break;
    default:
        throw new IllegalArgumentException("Unsupported status: " + status);
}
```

### 9.9 Try-Catch Statements

Use this format:

```java
try {
    statements;
} catch (Exception e) {
    handleException(e);
}
```

- Catch specific exceptions when possible.
- Do not silently ignore exceptions.
- Log or rethrow exceptions when needed.

## 10. White Space

### 10.1 Blank Lines

Use two blank lines:

- Between major sections of a source file.
- Between class and interface definitions.

Use one blank line:

- Between methods.
- Between local variable declarations and the first statement.
- Before block comments.
- Between logical sections inside a method.

### 10.2 Spaces

- Put a space after Java keywords before `(`.
- Do not put a space between a method name and `(`.
- Put a space after commas in argument lists.
- Put spaces around binary operators.
- Do not put spaces around unary operators.
- Put a space after casts.

Good:

```java
while (true) {
    total = price + shippingFee;
    printTotal(total);
    myMethod((int) value, name);
}
```

Bad:

```java
while(true) {
    total=price+shippingFee;
    printTotal (total);
    myMethod((int)value,name);
}
```

## 11. Naming Conventions

### 11.1 Packages

- Use lowercase package names.
- Avoid uppercase letters in package names.

Example:

```java
package controller;
package service;
package repository;
```

### 11.2 Classes

- Class names should be nouns.
- Use PascalCase.
- Use simple, descriptive names.
- Avoid unnecessary abbreviations.

Good:

```java
CustomerService
OrderController
PaymentTransaction
```

Bad:

```java
customer_service
OrdCtrl
paymenttransaction
```

### 11.3 Interfaces

- Interface names should use PascalCase like class names.
- Use names that describe capability or role.

Example:

```java
PaymentGateway
OrderRepository
Authenticatable
```

### 11.4 Methods

- Method names should be verbs or verb phrases.
- Use camelCase.
- The first letter must be lowercase.

Good:

```java
createOrder()
calculateTotal()
getCustomerName()
validatePayment()
```

Bad:

```java
CreateOrder()
orderTotal()
customer_name()
```

### 11.5 Variables

- Variable names should use camelCase.
- Variable names should be short but meaningful.
- Avoid one-character names except temporary loop counters.

Good:

```java
customerName
orderTotal
paymentStatus
```

Allowed for loops:

```java
for (int i = 0; i < size; i++) {
    // Implementation
}
```

### 11.6 Constants

- Constants must use uppercase letters.
- Separate words with underscores.
- Use `static final` for constants.

Good:

```java
private static final int MAX_LOGIN_ATTEMPTS = 5;
private static final String DEFAULT_ROLE = "CUSTOMER";
```

Bad:

```java
private static final int maxLoginAttempts = 5;
```

## 12. Programming Practices

### 12.1 Encapsulation

- Do not make instance or class variables public without a strong reason.
- Keep fields private when possible.
- Use getters and setters only when they are actually needed.
- Avoid exposing internal mutable data directly.

Good:

```java
private String customerName;

public String getCustomerName() {
    return customerName;
}
```

Bad:

```java
public String customerName;
```

### 12.2 Static Members

Access static variables and methods using the class name, not an object reference.

Good:

```java
PaymentUtil.validateSignature(signature);
```

Bad:

```java
paymentUtil.validateSignature(signature);
```

### 12.3 Constants Instead of Magic Numbers

Do not hard-code numeric literals directly, except common values such as `-1`, `0`, and `1` in simple counter logic.

Good:

```java
private static final int MAX_RETRY_COUNT = 3;

if (retryCount > MAX_RETRY_COUNT) {
    throw new IllegalStateException("Retry limit exceeded");
}
```

Bad:

```java
if (retryCount > 3) {
    throw new IllegalStateException("Retry limit exceeded");
}
```

### 12.4 Variable Assignments

- Do not assign several variables in one statement.
- Do not use embedded assignments to make code shorter.
- Keep assignments clear and separate.

Good:

```java
subtotal = itemPrice.add(shippingFee);
total = subtotal.subtract(discount);
```

Bad:

```java
total = (subtotal = itemPrice.add(shippingFee)).subtract(discount);
```

### 12.5 Parentheses

Use parentheses in complex expressions to make operator precedence clear.

Good:

```java
if ((orderTotal.compareTo(BigDecimal.ZERO) > 0) && customer.isActive()) {
    processOrder(order);
}
```

Bad:

```java
if (orderTotal.compareTo(BigDecimal.ZERO) > 0 && customer.isActive()) {
    processOrder(order);
}
```

## 13. Agent-Specific Rules

When an AI coding agent works on this project, it must follow these rules:

1. Do not rewrite unrelated code.
2. Do not rename files, packages, classes, methods, or variables unless requested.
3. Preserve the existing project architecture.
4. Keep changes small and focused on the requested task.
5. Follow Java naming conventions strictly.
6. Always use braces for `if`, `else`, `for`, `while`, and `do-while` blocks.
7. Avoid public fields unless the class is only a simple data structure and the project already uses that style.
8. Prefer private fields with clear methods for behavior.
9. Avoid magic numbers by creating named constants.
10. Avoid long methods; extract helper methods when logic becomes hard to read.
11. Avoid duplicate code; reuse existing services, utilities, repositories, or validators.
12. Catch specific exceptions and never swallow errors silently.
13. Do not add unnecessary comments.
14. Add Javadoc only for public APIs or complex business logic.
15. Keep formatting consistent with the surrounding code.
16. Before modifying a file, understand its package, role, dependencies, and related classes.
17. After coding, check that imports are clean and unused imports are removed.
18. Do not introduce new libraries unless explicitly requested.
19. Do not change database schema, API contracts, or business rules unless requested.
20. Do not break existing functionality while implementing a new requirement.

## 14. Code Review Checklist for Agents

Before finalizing code, check:

- [ ] File name matches the public class or interface name.
- [ ] Package statement is correct.
- [ ] Imports are necessary and organized.
- [ ] Class name uses PascalCase.
- [ ] Method and variable names use camelCase.
- [ ] Constants use UPPER_CASE_WITH_UNDERSCORES.
- [ ] Indentation uses 4 spaces.
- [ ] Lines are not unnecessarily long.
- [ ] Each variable declaration is on its own line.
- [ ] Control statements use braces.
- [ ] Methods are separated by blank lines.
- [ ] No unrelated code was changed.
- [ ] No magic numbers were introduced.
- [ ] Exceptions are handled properly.
- [ ] Comments are useful and not redundant.
- [ ] Code is readable and easy to maintain.

## 15. Recommended Prompt for Coding Agents

Use this prompt when asking an agent to code:

```text
Read and follow coding_invention.md before editing code.
Only implement the requested feature or fix.
Do not change unrelated files or business rules.
Follow Java naming, formatting, indentation, comment, and structure rules from the file.
After coding, briefly explain which files were changed and why.
```
