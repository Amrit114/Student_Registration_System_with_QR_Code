<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String uname = request.getParameter("username");
    String pass  = request.getParameter("password");

    if (uname == null || pass == null || uname.trim().isEmpty() || pass.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        Connection con = DriverManager.getConnection(
            "jdbc:oracle:thin:@localhost:1521:xe", "system", "system");

        PreparedStatement ps = con.prepareStatement(
            "SELECT role, username, regno FROM qr_users WHERE username=? AND password=?");
        ps.setString(1, uname.trim());
        ps.setString(2, pass);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            String role  = rs.getString("role");
            String regno = rs.getString("regno");

            session.setAttribute("username", uname.trim());
            session.setAttribute("role", role);
            if (regno != null) session.setAttribute("regno", regno);

            rs.close(); ps.close(); con.close();

            if ("ADMIN".equalsIgnoreCase(role)) {
                response.sendRedirect("adminDashbord.jsp");
            } else {
                response.sendRedirect("studentDashbord.jsp?regno=" + (regno != null ? regno : ""));
            }
        } else {
            rs.close(); ps.close(); con.close();
            // Redirect back to login with error parameter
            response.sendRedirect("login.jsp?error=1");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("login.jsp?error=2");
    }
%>