<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String regMsg = "";
    String regMsgType = "";

    String f_regno    = request.getParameter("regno");
    String f_cname    = request.getParameter("cname");
    String f_username = request.getParameter("username");
    String f_password = request.getParameter("password");
    String f_role     = request.getParameter("role");

    if (f_regno != null && f_cname != null && f_username != null && f_password != null && f_role != null) {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");

            // Verify regno exists in student_qr
            PreparedStatement psCheck = con.prepareStatement("SELECT * FROM student_qr WHERE regno=?");
            psCheck.setString(1, f_regno);
            ResultSet rsCheck = psCheck.executeQuery();

            if (!rsCheck.next()) {
                regMsg = "Registration No not found in student records. Please register as a student first.";
                regMsgType = "error";
            } else {
                // Restrict only 1 Admin
                if ("Admin".equalsIgnoreCase(f_role)) {
                    Statement st = con.createStatement();
                    ResultSet rsAdmin = st.executeQuery("SELECT COUNT(*) FROM qr_users WHERE role='Admin'");
                    rsAdmin.next();
                    if (rsAdmin.getInt(1) > 0) {
                        regMsg = "Only one Admin account is allowed in the system.";
                        regMsgType = "error";
                        con.close();
                    } else {
                        st.close();
                        // Insert user with cname
                        PreparedStatement psInsert = con.prepareStatement(
                            "INSERT INTO qr_users(username, password, regno, role, cname) VALUES(?,?,?,?,?)");
                        psInsert.setString(1, f_username);
                        psInsert.setString(2, f_password);
                        psInsert.setString(3, f_regno);
                        psInsert.setString(4, f_role);
                        psInsert.setString(5, f_cname);
                        int rows = psInsert.executeUpdate();
                        regMsg = (rows > 0) ? "Account created successfully! You can now login." : "Registration failed. Please try again.";
                        regMsgType = (rows > 0) ? "success" : "error";
                        psInsert.close();
                        con.close();
                    }
                } else {
                    PreparedStatement psInsert = con.prepareStatement(
                        "INSERT INTO qr_users(username, password, regno, role, cname) VALUES(?,?,?,?,?)");
                    psInsert.setString(1, f_username);
                    psInsert.setString(2, f_password);
                    psInsert.setString(3, f_regno);
                    psInsert.setString(4, f_role);
                    psInsert.setString(5, f_cname);
                    int rows = psInsert.executeUpdate();
                    regMsg = (rows > 0) ? "Account created successfully! You can now login." : "Registration failed. Please try again.";
                    regMsgType = (rows > 0) ? "success" : "error";
                    psInsert.close();
                    con.close();
                }
            }
        } catch (Exception e) {
            regMsg = "Database error: " + e.getMessage();
            regMsgType = "error";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register — EduQR</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --ink: #0d1117; --paper: #f5f0e8; --accent: #e8490f;
            --accent2: #1a56e8; --muted: #6b7280; --border: #e2d9cc;
        }
        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--ink);
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            padding: 32px 20px; position: relative; overflow-x: hidden;
        }
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image:
                linear-gradient(rgba(26,86,232,.06) 1px, transparent 1px),
                linear-gradient(90deg, rgba(26,86,232,.06) 1px, transparent 1px);
            background-size: 48px 48px;
        }
        .wrap {
            position: relative; z-index: 1;
            width: 100%; max-width: 500px;
        }
        .brand {
            text-align: center; margin-bottom: 28px;
        }
        .brand-logo {
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem; font-weight: 800;
            color: #fff; letter-spacing: -1px;
        }
        .brand-logo span { color: var(--accent); }
        .brand-sub { font-size: 0.8rem; color: rgba(255,255,255,.4); margin-top: 4px; }

        .card {
            background: var(--paper); border-radius: 16px; overflow: hidden;
        }
        .card-header {
            background: var(--accent2);
            padding: 24px 36px 20px;
        }
        .card-header h1 {
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem; font-weight: 800;
            color: #fff; margin-bottom: 4px;
        }
        .card-header p { font-size: 0.82rem; color: rgba(255,255,255,.75); }
        .card-body { padding: 28px 36px 32px; }

        .form-row { display: flex; gap: 16px; }
        .form-row .form-group { flex: 1; }

        .form-group { margin-bottom: 18px; }
        .form-label {
            display: block; font-size: 0.78rem; font-weight: 500;
            letter-spacing: 0.5px; text-transform: uppercase;
            color: var(--muted); margin-bottom: 7px;
        }
        .form-control {
            width: 100%; padding: 12px 15px;
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 8px;
            font-family: 'DM Sans', sans-serif;
            font-size: 0.93rem; color: var(--ink);
            transition: border-color .2s, box-shadow .2s;
            outline: none; appearance: none;
        }
        .form-control:focus {
            border-color: var(--accent2);
            box-shadow: 0 0 0 3px rgba(26,86,232,.1);
        }
        select.form-control { cursor: pointer; }

        .btn-register {
            width: 100%; padding: 14px;
            background: var(--ink); color: #fff;
            border: none; border-radius: 8px;
            font-family: 'Syne', sans-serif;
            font-size: 1rem; font-weight: 700;
            cursor: pointer; letter-spacing: 0.5px;
            transition: background .2s, transform .15s;
            margin-top: 6px;
        }
        .btn-register:hover { background: #1c2733; transform: translateY(-1px); }

        .divider {
            display: flex; align-items: center; gap: 12px;
            margin: 20px 0;
        }
        .divider::before, .divider::after {
            content: ''; flex: 1; height: 1px; background: var(--border);
        }
        .divider span { font-size: 0.75rem; color: var(--muted); }

        .login-link {
            display: block; width: 100%; padding: 13px;
            background: transparent; border: 1.5px solid var(--border);
            border-radius: 8px; font-size: 0.9rem; font-weight: 500;
            color: var(--ink); text-align: center; text-decoration: none;
            transition: border-color .2s, background .2s;
        }
        .login-link:hover { border-color: var(--ink); background: rgba(13,17,23,.05); }

        .alert {
            padding: 13px 16px; border-radius: 8px;
            font-size: 0.875rem; margin-bottom: 20px;
            display: flex; align-items: flex-start; gap: 10px;
        }
        .alert-error   { background: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; }
        .alert-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }

        @keyframes fadeUp {
            from { opacity:0; transform: translateY(20px); }
            to   { opacity:1; transform: translateY(0); }
        }
        .wrap { animation: fadeUp .5s ease both; }

        .back-btn {
            display: flex; align-items: center; justify-content: center;
            gap: 6px; margin-bottom: 20px;
            color: rgba(255,255,255,.5); text-decoration: none;
            font-size: 0.85rem; transition: color .2s;
        }
        .back-btn:hover { color: #fff; }
    </style>
</head>
<body>
    <div class="wrap">
        <a href="index.jsp" class="back-btn">← Back to Home</a>

        <div class="brand">
            <div class="brand-logo">Edu<span>QR</span></div>
            <div class="brand-sub">Student Data & QR Management System</div>
        </div>

        <div class="card">
            <div class="card-header">
                <h1>Create Account</h1>
                <p>Fill in your details to register</p>
            </div>
            <div class="card-body">

                <% if (!regMsg.isEmpty()) { %>
                <div class="alert alert-<%= regMsgType %>">
                    <%= "error".equals(regMsgType) ? "⚠️" : "✅" %> <%= regMsg %>
                </div>
                <% if ("success".equals(regMsgType)) { %>
                <a href="login.jsp" style="display:block;text-align:center;margin-bottom:16px;color:var(--accent2);font-weight:500;text-decoration:none;">← Back to Login</a>
                <% } } %>

                <form method="post">
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="regno">Registration No *</label>
                            <input type="text" id="regno" name="regno" class="form-control"
                                   placeholder="e.g. 2200100" required value="<%= f_regno != null ? f_regno : "" %>">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="role">Role *</label>
                            <select id="role" name="role" class="form-control" required>
                                <option value="">-- Select --</option>
                                <option value="Student" <%= "Student".equals(f_role) ? "selected" : "" %>>Student</option>
                                <option value="Admin"   <%= "Admin".equals(f_role)   ? "selected" : "" %>>Admin</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="cname">College Name *</label>
                        <input type="text" id="cname" name="cname" class="form-control"
                               placeholder="e.g. ABC Institute of Technology" required value="<%= f_cname != null ? f_cname : "" %>">
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="username">Username *</label>
                            <input type="text" id="username" name="username" class="form-control"
                                   placeholder="Choose a username" required value="<%= f_username != null ? f_username : "" %>">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="password">Password *</label>
                            <input type="password" id="password" name="password" class="form-control"
                                   placeholder="Create a password" required>
                        </div>
                    </div>

                    <button type="submit" class="btn-register">Create Account →</button>
                </form>

                <div class="divider"><span>Already have an account?</span></div>
                <a href="login.jsp" class="login-link">🔑 Sign In</a>

            </div>
        </div>
    </div>
</body>
</html>