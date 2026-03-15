<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String regno = request.getParameter("regno");
    if (regno != null && !regno.trim().isEmpty()) {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1521:xe", "system", "system");

            PreparedStatement ps = con.prepareStatement(
                "SELECT regno, name, branch, mobile, email FROM student_qr WHERE regno=?");
            ps.setString(1, regno);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
%>
<table>
    <tr>
        <td>Registration No</td>
        <td><strong><%= rs.getString("regno") %></strong></td>
    </tr>
    <tr>
        <td>Name</td>
        <td><strong><%= rs.getString("name") %></strong></td>
    </tr>
    <tr>
        <td>Branch</td>
        <td><%= rs.getString("branch") %></td>
    </tr>
    <tr>
        <td>Mobile</td>
        <td><%= rs.getString("mobile") != null ? rs.getString("mobile") : "—" %></td>
    </tr>
    <tr>
        <td>Email</td>
        <td><%= rs.getString("email") != null ? rs.getString("email") : "—" %></td>
    </tr>
</table>
<div class="result-qr">
    <img src="ShowQRImageServlet?regno=<%= rs.getString("regno") %>" alt="QR Code">
</div>
<%
            } else {
                out.println("<div style='padding:16px;color:#b91c1c;text-align:center;'>❌ No student found for Reg No: " + regno + "</div>");
            }
            con.close();
        } catch (Exception e) {
            out.println("<div style='padding:16px;color:#b91c1c;'>Error: " + e.getMessage() + "</div>");
        }
    } else {
        out.println("<div style='padding:16px;color:#b91c1c;text-align:center;'>❌ Invalid or missing QR Code data.</div>");
    }
%>