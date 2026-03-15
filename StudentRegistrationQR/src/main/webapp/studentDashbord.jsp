<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String user  = (String)session.getAttribute("username");
    String regno = request.getParameter("regno");
    if (regno == null || regno.trim().isEmpty()) regno = (String)session.getAttribute("regno");

    if (user == null) { response.sendRedirect("login.jsp"); return; }

    String stName = "", stBranch = "", stEmail = "", stMobile = "";
    boolean found = false;

    Connection con = null;
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "system");

        PreparedStatement ps = con.prepareStatement(
            "SELECT name, branch, email, mobile FROM student_qr WHERE regno=?");
        ps.setString(1, regno);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            stName   = rs.getString("name");
            stBranch = rs.getString("branch");
            stEmail  = rs.getString("email");
            stMobile = rs.getString("mobile");
            found = true;
        }
        rs.close(); ps.close();
    } catch(Exception e) {
        // error shown in page
    } finally {
        if (con != null) try { con.close(); } catch(Exception ex) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile — EduQR</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --ink: #0d1117; --paper: #f5f0e8; --accent: #e8490f;
            --accent2: #1a56e8; --muted: #6b7280; --border: #e2d9cc;
        }
        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--paper); min-height: 100vh;
        }

        .topbar {
            background: var(--ink); height: 60px;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 40px;
        }
        .topbar-brand {
            font-family: 'Syne', sans-serif;
            font-size: 1.15rem; font-weight: 800;
            color: #fff; letter-spacing: -0.5px;
        }
        .topbar-brand span { color: var(--accent); }
        .topbar-right {
            display: flex; align-items: center; gap: 20px;
        }
        .topbar-user {
            font-size: 0.85rem; color: rgba(255,255,255,.6);
        }
        .topbar-user strong { color: #fff; }
        .btn-logout {
            padding: 8px 18px; background: transparent;
            border: 1px solid rgba(255,255,255,.25);
            border-radius: 6px; color: rgba(255,255,255,.7);
            text-decoration: none; font-size: 0.82rem;
            transition: border-color .2s, color .2s;
        }
        .btn-logout:hover { border-color: var(--accent); color: #fff; }

        .container {
            max-width: 900px; margin: 48px auto; padding: 0 24px;
        }

        /* Profile Header */
        .profile-header {
            background: var(--ink); border-radius: 16px;
            padding: 36px 40px; margin-bottom: 24px;
            display: flex; align-items: center; gap: 32px;
            position: relative; overflow: hidden;
        }
        .profile-header::before {
            content: '';
            position: absolute; right: -60px; top: -60px;
            width: 240px; height: 240px; border-radius: 50%;
            background: rgba(232,73,15,.12);
        }
        .avatar {
            width: 80px; height: 80px; border-radius: 50%;
            background: var(--accent);
            display: flex; align-items: center; justify-content: center;
            font-family: 'Syne', sans-serif;
            font-size: 2rem; font-weight: 800;
            color: #fff; flex-shrink: 0;
            position: relative; z-index: 1;
        }
        .profile-info { position: relative; z-index: 1; }
        .profile-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.8rem; font-weight: 800;
            color: #fff; letter-spacing: -0.5px;
        }
        .profile-meta {
            font-size: 0.85rem; color: rgba(255,255,255,.5);
            margin-top: 6px; display: flex; gap: 16px;
        }
        .profile-meta span { display: flex; align-items: center; gap: 5px; }

        /* Details Card */
        .details-card {
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 14px; overflow: hidden;
            margin-bottom: 24px;
        }
        .details-card-header {
            padding: 20px 28px;
            border-bottom: 1px solid var(--border);
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 700;
        }
        .details-grid {
            display: grid; grid-template-columns: 1fr 1fr;
            gap: 0;
        }
        .detail-item {
            padding: 20px 28px;
            border-bottom: 1px solid var(--border);
            border-right: 1px solid var(--border);
        }
        .detail-item:nth-child(even) { border-right: none; }
        .detail-item:nth-last-child(-n+2) { border-bottom: none; }
        .detail-label {
            font-size: 0.72rem; font-weight: 600;
            text-transform: uppercase; letter-spacing: 1px;
            color: var(--muted); margin-bottom: 6px;
        }
        .detail-value {
            font-size: 1rem; color: var(--ink); font-weight: 500;
        }

        /* QR Card */
        .qr-card {
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 14px; padding: 28px;
            display: flex; align-items: center; gap: 28px;
        }
        .qr-image img {
            width: 140px; height: 140px;
            border: 2px solid var(--border);
            border-radius: 8px; padding: 6px;
            background: #fafafa;
        }
        .qr-info h3 {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem; font-weight: 700;
            margin-bottom: 8px;
        }
        .qr-info p { font-size: 0.85rem; color: var(--muted); line-height: 1.6; }

        .error-box {
            background: #fef2f2; border: 1.5px solid #fecaca;
            border-radius: 12px; padding: 24px;
            color: #b91c1c; text-align: center;
        }

        @keyframes fadeUp {
            from { opacity:0; transform: translateY(16px); }
            to   { opacity:1; transform: translateY(0); }
        }
        .profile-header { animation: fadeUp .4s ease both; }
        .details-card   { animation: fadeUp .4s .1s ease both; }
        .qr-card        { animation: fadeUp .4s .2s ease both; }
    </style>
</head>
<body>

    <nav class="topbar">
        <div class="topbar-brand">Edu<span>QR</span></div>
        <div class="topbar-right">
            <div class="topbar-user">Logged in as <strong><%= user %></strong></div>
            <a href="logout.jsp" class="btn-logout">🚪 Logout</a>
        </div>
    </nav>

    <div class="container">
        <% if (found) { %>

        <!-- Profile Header -->
        <div class="profile-header">
            <div class="avatar"><%= stName.length() > 0 ? stName.charAt(0) : "?" %></div>
            <div class="profile-info">
                <div class="profile-name"><%= stName %></div>
                <div class="profile-meta">
                    <span>🎓 <%= stBranch %></span>
                    <span>🆔 Reg No: <%= regno %></span>
                </div>
            </div>
        </div>

        <!-- Details -->
        <div class="details-card">
            <div class="details-card-header">Student Information</div>
            <div class="details-grid">
                <div class="detail-item">
                    <div class="detail-label">Registration No</div>
                    <div class="detail-value"><%= regno %></div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Full Name</div>
                    <div class="detail-value"><%= stName %></div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Branch</div>
                    <div class="detail-value"><%= stBranch %></div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Mobile</div>
                    <div class="detail-value"><%= stMobile != null && !stMobile.isEmpty() ? stMobile : "—" %></div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Email Address</div>
                    <div class="detail-value"><%= stEmail != null && !stEmail.isEmpty() ? stEmail : "—" %></div>
                </div>
                <div class="detail-item">
                    <div class="detail-label">Username</div>
                    <div class="detail-value"><%= user %></div>
                </div>
            </div>
        </div>

        <!-- QR Code -->
        <div class="qr-card">
            <div class="qr-image">
                <img src="ShowQRImageServlet?regno=<%= regno %>" alt="Your QR Code">
            </div>
            <div class="qr-info">
                <h3>Your Student QR Code</h3>
                <p>This QR code uniquely identifies you. It contains your registration number, name, branch, mobile, and email — and can be scanned at any time for quick verification.</p>
            </div>
        </div>

        <% } else { %>
        <div class="error-box">
            <h2 style="margin-bottom:8px;">⚠️ Student Record Not Found</h2>
            <p>No data found for registration number: <strong><%= regno %></strong></p>
            <p style="margin-top:12px;"><a href="logout.jsp" style="color:var(--accent2);">← Logout and try again</a></p>
        </div>
        <% } %>
    </div>

</body>
</html>