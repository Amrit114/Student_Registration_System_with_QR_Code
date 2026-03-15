<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page language="java" %>
<%
    String user = (String)session.getAttribute("username");
    String role = (String)session.getAttribute("role");
    if (user == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp"); return;
    }

    String regno = request.getParameter("regno");
    String msg = "";
    String msgType = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        regno = request.getParameter("regno");
        String name   = request.getParameter("name");
        String branch = request.getParameter("branch");
        String mobile = request.getParameter("mobile");
        String email  = request.getParameter("email");

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");

            PreparedStatement ps = con.prepareStatement(
                "UPDATE student_qr SET name=?, branch=?, mobile=?, email=? WHERE regno=?");
            ps.setString(1, name);
            ps.setString(2, branch);
            ps.setString(3, mobile);
            ps.setString(4, email);
            ps.setString(5, regno);

            int rows = ps.executeUpdate();
            msg = (rows > 0) ? "Student details updated successfully." : "Update failed. No changes were made.";
            msgType = (rows > 0) ? "success" : "error";
            ps.close(); con.close();
        } catch(Exception e) {
            msg = "Database error: " + e.getMessage();
            msgType = "error";
        }
    }

    // Fetch student data to prefill form
    String stName = "", stBranch = "", stMobile = "", stEmail = "";
    if (regno != null && !regno.trim().isEmpty()) {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
            PreparedStatement ps = con.prepareStatement("SELECT * FROM student_qr WHERE regno=?");
            ps.setString(1, regno);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stName   = rs.getString("name");
                stBranch = rs.getString("branch");
                stMobile = rs.getString("mobile");
                stEmail  = rs.getString("email");
            }
            rs.close(); ps.close(); con.close();
        } catch(Exception e) {
            if (msg.isEmpty()) { msg = "Error fetching record: " + e.getMessage(); msgType = "error"; }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Student — EduQR</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --ink: #0d1117; --paper: #f5f0e8; --accent: #e8490f;
            --accent2: #1a56e8; --muted: #6b7280; --border: #e2d9cc;
            --sidebar-w: 240px;
        }
        body { font-family: 'DM Sans', sans-serif; background: var(--paper); }

        .sidebar { position: fixed; left: 0; top: 0; bottom: 0; width: var(--sidebar-w); background: var(--ink); color: #fff; display: flex; flex-direction: column; z-index: 50; }
        .sidebar-brand { padding: 28px 24px 20px; border-bottom: 1px solid rgba(255,255,255,.08); }
        .sidebar-brand-name { font-family: 'Syne', sans-serif; font-size: 1.3rem; font-weight: 800; }
        .sidebar-brand-name span { color: var(--accent); }
        .sidebar-brand-role { font-size: 0.72rem; color: rgba(255,255,255,.4); text-transform: uppercase; letter-spacing: 1.5px; margin-top: 4px; }
        .sidebar-nav { flex: 1; padding: 16px 0; }
        .nav-section-label { font-size: 0.65rem; font-weight: 600; text-transform: uppercase; letter-spacing: 2px; color: rgba(255,255,255,.25); padding: 16px 24px 8px; }
        .nav-item { display: flex; align-items: center; gap: 12px; padding: 11px 24px; color: rgba(255,255,255,.65); text-decoration: none; font-size: 0.9rem; transition: background .15s; border-left: 3px solid transparent; }
        .nav-item:hover, .nav-item.active { background: rgba(255,255,255,.06); color: #fff; border-left-color: var(--accent); }
        .nav-icon { font-size: 1rem; width: 20px; text-align: center; }
        .sidebar-user { padding: 16px 24px; border-top: 1px solid rgba(255,255,255,.08); font-size: 0.82rem; color: rgba(255,255,255,.5); }
        .sidebar-user strong { color: #fff; display: block; }

        .main { margin-left: var(--sidebar-w); padding: 36px; }
        .page-header { margin-bottom: 28px; }
        .page-header h1 { font-family: 'Syne', sans-serif; font-size: 1.8rem; font-weight: 800; letter-spacing: -1px; }
        .page-header p { color: var(--muted); font-size: 0.9rem; margin-top: 4px; }

        .form-card {
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 14px; overflow: hidden; max-width: 620px;
        }
        .form-card-header {
            background: var(--accent2); padding: 22px 32px;
        }
        .form-card-header h2 { font-family: 'Syne', sans-serif; font-size: 1.1rem; font-weight: 700; color: #fff; }
        .form-card-header p { font-size: 0.82rem; color: rgba(255,255,255,.75); margin-top: 2px; }
        .form-card-body { padding: 28px 32px; }

        .alert { padding: 12px 16px; border-radius: 8px; font-size: 0.875rem; margin-bottom: 20px; }
        .alert-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-error   { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }

        .form-row { display: flex; gap: 18px; }
        .form-row .form-group { flex: 1; }
        .form-group { margin-bottom: 20px; }
        .form-label { display: block; font-size: 0.78rem; font-weight: 500; letter-spacing: 0.5px; text-transform: uppercase; color: var(--muted); margin-bottom: 7px; }
        .form-control {
            width: 100%; padding: 12px 15px;
            background: var(--paper); border: 1.5px solid var(--border);
            border-radius: 8px; font-family: 'DM Sans', sans-serif;
            font-size: 0.93rem; color: var(--ink);
            transition: border-color .2s, box-shadow .2s; outline: none; appearance: none;
        }
        .form-control:focus { border-color: var(--accent2); background: #fff; box-shadow: 0 0 0 3px rgba(26,86,232,.1); }
        .form-control:disabled { background: #f3f4f6; color: var(--muted); cursor: not-allowed; }

        .form-actions { display: flex; gap: 12px; justify-content: flex-end; padding-top: 8px; border-top: 1px solid var(--border); margin-top: 8px; }
        .btn-submit { padding: 12px 28px; background: var(--accent2); color: #fff; border: none; border-radius: 8px; font-family: 'Syne', sans-serif; font-size: 0.95rem; font-weight: 700; cursor: pointer; transition: background .2s; }
        .btn-submit:hover { background: #1345c5; }
        .btn-cancel { padding: 12px 20px; background: transparent; color: var(--muted); border: 1.5px solid var(--border); border-radius: 8px; font-family: 'DM Sans', sans-serif; font-size: 0.92rem; cursor: pointer; text-decoration: none; display: inline-block; transition: border-color .2s, color .2s; }
        .btn-cancel:hover { border-color: var(--ink); color: var(--ink); }

        .no-student { text-align: center; padding: 48px; color: var(--muted); }
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
            <a href="manageStudent.jsp" class="nav-item active"><span class="nav-icon">👨‍🎓</span> Manage Students</a>
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
        <div class="page-header">
            <h1>Edit Student</h1>
            <p>Update the student's details below</p>
        </div>

        <div class="form-card">
            <div class="form-card-header">
                <h2>✏️ Editing: Reg No <%= regno %></h2>
                <p>Only Name, Branch, Mobile and Email can be updated</p>
            </div>
            <div class="form-card-body">

                <% if (!msg.isEmpty()) { %>
                <div class="alert alert-<%= msgType %>">
                    <%= "success".equals(msgType) ? "✅" : "❌" %> <%= msg %>
                </div>
                <% } %>

                <% if (regno != null && !regno.trim().isEmpty()) { %>
                <form method="post">
                    <input type="hidden" name="regno" value="<%= regno %>">

                    <div class="form-group">
                        <label class="form-label">Registration No (Read-only)</label>
                        <input type="text" class="form-control" value="<%= regno %>" disabled>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="name">Full Name *</label>
                        <input type="text" id="name" name="name" class="form-control"
                               value="<%= stName %>" required maxlength="100">
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="branch">Branch</label>
                            <select id="branch" name="branch" class="form-control">
                                <option value="">— Select Branch —</option>
                                <option value="CSE" <%= "CSE".equals(stBranch)?"selected":"" %>>CSE</option>
                                <option value="ECE" <%= "ECE".equals(stBranch)?"selected":"" %>>ECE</option>
                                <option value="ME"  <%= "ME".equals(stBranch) ?"selected":"" %>>ME</option>
                                <option value="CE"  <%= "CE".equals(stBranch) ?"selected":"" %>>CE</option>
                                <option value="EE"  <%= "EE".equals(stBranch) ?"selected":"" %>>EE</option>
                                <option value="OTHER" <%= "OTHER".equals(stBranch)?"selected":"" %>>OTHER</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="mobile">Mobile</label>
                            <input type="text" id="mobile" name="mobile" class="form-control"
                                   value="<%= stMobile != null ? stMobile : "" %>">
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="email">Email</label>
                        <input type="email" id="email" name="email" class="form-control"
                               value="<%= stEmail != null ? stEmail : "" %>">
                    </div>

                    <div class="form-actions">
                        <a href="manageStudent.jsp" class="btn-cancel">Cancel</a>
                        <button type="submit" class="btn-submit">Update Student →</button>
                    </div>
                </form>
                <% } else { %>
                <div class="no-student">
                    <p>❌ No student selected. Please go back and choose a student to edit.</p>
                    <a href="manageStudent.jsp" style="color:var(--accent2);text-decoration:none;margin-top:12px;display:inline-block;">← Back to Manage Students</a>
                </div>
                <% } %>
            </div>
        </div>
    </main>
</body>
</html>