<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.io.*,javax.imageio.ImageIO" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="com.google.zxing.BarcodeFormat" %>
<%@ page import="com.google.zxing.qrcode.QRCodeWriter" %>
<%@ page import="com.google.zxing.WriterException" %>
<%@ page import="com.google.zxing.common.BitMatrix" %>
<%
    String user = (String)session.getAttribute("username");
    String role = (String)session.getAttribute("role");
    if (user == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp"); return;
    }

    // --- Step 1: Get form inputs ---
    String regno  = request.getParameter("id");
    String name   = request.getParameter("n");
    String branch = request.getParameter("branch");
    String mobile = request.getParameter("mobile");
    String email  = request.getParameter("email");

    // --- Step 2: Build QR data text ---
    String qrData = "RegNo: " + regno +
                    " | Name: " + name +
                    " | Branch: " + branch +
                    " | Mobile: " + mobile +
                    " | Email: " + email;

    int size = 250;
    QRCodeWriter qrCodeWriter = new QRCodeWriter();
    BitMatrix bitMatrix = null;
    try {
        bitMatrix = qrCodeWriter.encode(qrData, BarcodeFormat.QR_CODE, size, size);
    } catch (WriterException e) {
        e.printStackTrace();
    }

    // --- Step 3: Convert to image ---
    BufferedImage qrImage = new BufferedImage(size, size, BufferedImage.TYPE_INT_RGB);
    for (int x = 0; x < size; x++) {
        for (int y = 0; y < size; y++) {
            qrImage.setRGB(x, y, bitMatrix.get(x, y) ? 0xFF000000 : 0xFFFFFFFF);
        }
    }

    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    ImageIO.write(qrImage, "png", baos);
    byte[] qrBytes = baos.toByteArray();

    // --- Step 4: Insert into Oracle DB ---
    String dbMsg = "";
    String dbMsgType = "";
    Connection con = null;
    PreparedStatement ps = null;
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "system");

        String sql = "INSERT INTO student_qr (regno, name, branch, mobile, email, qr_data, qr_image) VALUES (?, ?, ?, ?, ?, ?, ?)";
        ps = con.prepareStatement(sql);
        ps.setString(1, regno);
        ps.setString(2, name);
        ps.setString(3, branch);
        ps.setString(4, mobile);
        ps.setString(5, email);
        ps.setString(6, qrData);
        ps.setBytes(7, qrBytes);

        int rows = ps.executeUpdate();
        dbMsg = (rows > 0) ? "Student registered and QR code saved successfully!" : "Failed to save student record.";
        dbMsgType = (rows > 0) ? "success" : "error";
    } catch (SQLIntegrityConstraintViolationException e) {
        dbMsg = "Duplicate Entry: A student with Reg No " + regno + " already exists.";
        dbMsgType = "error";
    } catch (Exception e) {
        dbMsg = "Database Error: " + e.getMessage();
        dbMsgType = "error";
    } finally {
        if (ps  != null) try { ps.close();  } catch(Exception ex) {}
        if (con != null) try { con.close(); } catch(Exception ex) {}
    }

    // --- Step 5: Encode image for display ---
    String base64 = java.util.Base64.getEncoder().encodeToString(qrBytes);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QR Generated — EduQR</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --ink: #0d1117; --paper: #f5f0e8; --accent: #e8490f;
            --muted: #6b7280; --border: #e2d9cc; --sidebar-w: 240px;
        }
        body { font-family: 'DM Sans', sans-serif; background: var(--paper); }

        .sidebar {
            position: fixed; left: 0; top: 0; bottom: 0; width: var(--sidebar-w);
            background: var(--ink); color: #fff; display: flex; flex-direction: column; z-index: 50;
        }
        .sidebar-brand { padding: 28px 24px 20px; border-bottom: 1px solid rgba(255,255,255,.08); }
        .sidebar-brand-name { font-family: 'Syne', sans-serif; font-size: 1.3rem; font-weight: 800; letter-spacing: -0.5px; }
        .sidebar-brand-name span { color: var(--accent); }
        .sidebar-brand-role { font-size: 0.72rem; color: rgba(255,255,255,.4); text-transform: uppercase; letter-spacing: 1.5px; margin-top: 4px; }
        .sidebar-nav { flex: 1; padding: 16px 0; }
        .nav-section-label { font-size: 0.65rem; font-weight: 600; text-transform: uppercase; letter-spacing: 2px; color: rgba(255,255,255,.25); padding: 16px 24px 8px; }
        .nav-item { display: flex; align-items: center; gap: 12px; padding: 11px 24px; color: rgba(255,255,255,.65); text-decoration: none; font-size: 0.9rem; transition: background .15s, color .15s; border-left: 3px solid transparent; }
        .nav-item:hover { background: rgba(255,255,255,.06); color: #fff; border-left-color: var(--accent); }
        .nav-icon { font-size: 1rem; width: 20px; text-align: center; }
        .sidebar-user { padding: 16px 24px; border-top: 1px solid rgba(255,255,255,.08); font-size: 0.82rem; color: rgba(255,255,255,.5); }
        .sidebar-user strong { color: #fff; display: block; font-size: 0.88rem; }

        .main { margin-left: var(--sidebar-w); padding: 36px; display: flex; align-items: flex-start; justify-content: center; min-height: 100vh; }

        .result-card {
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 16px; overflow: hidden;
            max-width: 520px; width: 100%;
        }
        .result-header {
            padding: 24px 32px;
            background: <%= "success".equals(dbMsgType) ? "var(--accent)" : "#dc2626" %>;
        }
        .result-header h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.25rem; font-weight: 800; color: #fff;
        }
        .result-header p { font-size: 0.83rem; color: rgba(255,255,255,.75); margin-top: 4px; }

        .result-body { padding: 32px; }

        .qr-display {
            text-align: center; margin-bottom: 28px;
            padding: 24px;
            background: var(--paper); border-radius: 12px;
            border: 1.5px solid var(--border);
        }
        .qr-display img {
            width: 160px; height: 160px;
            border: 3px solid var(--border);
            border-radius: 8px; padding: 8px; background: #fff;
        }
        .qr-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem; font-weight: 700;
            margin-top: 12px;
        }
        .qr-regno { font-size: 0.85rem; color: var(--muted); margin-top: 4px; }

        .student-details { margin-bottom: 28px; }
        .detail-row {
            display: flex; justify-content: space-between;
            padding: 10px 0; border-bottom: 1px solid var(--border);
            font-size: 0.9rem;
        }
        .detail-row:last-child { border-bottom: none; }
        .detail-key { color: var(--muted); font-weight: 500; }
        .detail-val { font-weight: 500; color: var(--ink); }

        .actions { display: flex; gap: 12px; }
        .btn {
            flex: 1; padding: 12px;
            border-radius: 8px; font-family: 'DM Sans', sans-serif;
            font-size: 0.92rem; font-weight: 500;
            text-align: center; text-decoration: none;
            cursor: pointer; border: none; transition: all .2s;
        }
        .btn-primary { background: var(--accent); color: #fff; }
        .btn-primary:hover { background: #c73d0c; }
        .btn-outline { background: transparent; border: 1.5px solid var(--border); color: var(--ink); }
        .btn-outline:hover { border-color: var(--ink); background: rgba(13,17,23,.04); }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="sidebar-brand-name">Edu<span>QR</span></div>
            <div class="sidebar-brand-role">Admin Panel</div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section-label">Navigation</div>
            <a href="adminDashbord.jsp" class="nav-item"><span class="nav-icon">📊</span> Dashboard</a>
            <a href="reg.jsp" class="nav-item"><span class="nav-icon">📝</span> Register Student</a>
            <a href="manageStudent.jsp" class="nav-item"><span class="nav-icon">👨‍🎓</span> Manage Students</a>
            <a href="viewStudent.jsp" class="nav-item"><span class="nav-icon">🔍</span> View Students</a>
            <a href="printID.jsp" class="nav-item"><span class="nav-icon">🖨️</span> Print ID Cards</a>
            <a href="readQR.jsp" class="nav-item"><span class="nav-icon">📷</span> Scan QR Code</a>
        </nav>
        <div class="sidebar-user">
            <strong><%= user %></strong>
            <a href="logout.jsp" style="color:rgba(255,255,255,.4);text-decoration:none;font-size:0.8rem;">🚪 Logout</a>
        </div>
    </aside>

    <main class="main">
        <div class="result-card">
            <div class="result-header">
                <h2><%= "success".equals(dbMsgType) ? "✅ QR Code Generated!" : "❌ Error Occurred" %></h2>
                <p><%= dbMsg %></p>
            </div>
            <div class="result-body">
                <% if ("success".equals(dbMsgType)) { %>
                <div class="qr-display">
                    <img src="data:image/png;base64,<%= base64 %>" alt="QR Code for <%= name %>">
                    <div class="qr-name"><%= name %></div>
                    <div class="qr-regno">Reg No: <%= regno %></div>
                </div>

                <div class="student-details">
                    <div class="detail-row">
                        <span class="detail-key">Branch</span>
                        <span class="detail-val"><%= branch != null && !branch.isEmpty() ? branch : "—" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-key">Mobile</span>
                        <span class="detail-val"><%= mobile != null && !mobile.isEmpty() ? mobile : "—" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-key">Email</span>
                        <span class="detail-val"><%= email != null && !email.isEmpty() ? email : "—" %></span>
                    </div>
                </div>
                <% } %>

                <div class="actions">
                    <a href="reg.jsp" class="btn btn-primary">+ Add Another Student</a>
                    <a href="manageStudent.jsp" class="btn btn-outline">View All Students</a>
                </div>
            </div>
        </div>
    </main>
</body>
</html>