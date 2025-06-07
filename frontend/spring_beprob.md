Let's talk about our problem:
1. We are migrating from the Node.js backend in the backend folder to the Spring Boot backend in the backend_springboot folder. It is important that we focus on making the APIs and the data types handling in the Java Spring boot backend identical to the one in the Node.js backend.

We are experiencing those problems when running the Spring Boot backend that the Node.js backend did not have these problems:

In the dashboard screen, the Revenue (doanh thu) always displays 0d, when all of the things are done. The payment and the statistics page got the revenue done, while the dashboard screen still 0. The dashboard screen should take the summation of the statistics page or the payment page with all of the amount of money paid, fix it like that.

In the household management page, it displays Apartment N/A and Household Leader N/A. Only when I press to see more, it displays the members of it in the detail page. And also, outside it displays 
- Căn hộ N/A
Chủ hộ N/A
Diện tích: 0.0 m2
Trạng thái: unknown

This means the household management frontend home page did not fetch the data from the backend at all. Re-check the Node.js backend on how it handled these cases.

The financial report page is also experiencing the problem where all revenue is 0, making the boxes 0 and the chart has no column.