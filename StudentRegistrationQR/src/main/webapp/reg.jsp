<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String user = (String)session.getAttribute("username");
    String role = (String)session.getAttribute("role");
    if (user == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register Student — EduQR</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --ink: #0d1117; --paper: #f5f0e8; --accent: #e8490f;
            --accent2: #1a56e8; --muted: #6b7280; --border: #e2d9cc;
            --sidebar-w: 240px;
        }
        body { font-family: 'DM Sans', sans-serif; background: var(--paper); }

        /* ── SIDEBAR (shared) ── */
        .sidebar {
            position: fixed; left: 0; top: 0; bottom: 0;
            width: var(--sidebar-w);
            background: var(--ink); color: #fff;
            display: flex; flex-direction: column; z-index: 50;
        }
        .sidebar-brand { padding: 28px 24px 20px; border-bottom: 1px solid rgba(255,255,255,.08); }
        .sidebar-brand-name { font-family: 'Syne', sans-serif; font-size: 1.3rem; font-weight: 800; letter-spacing: -0.5px; }
        .sidebar-brand-name span { color: var(--accent); }
        .sidebar-brand-role { font-size: 0.72rem; color: rgba(255,255,255,.4); text-transform: uppercase; letter-spacing: 1.5px; margin-top: 4px; }
        .sidebar-nav { flex: 1; padding: 16px 0; overflow-y: auto; }
        .nav-section-label { font-size: 0.65rem; font-weight: 600; text-transform: uppercase; letter-spacing: 2px; color: rgba(255,255,255,.25); padding: 16px 24px 8px; }
        .nav-item { display: flex; align-items: center; gap: 12px; padding: 11px 24px; color: rgba(255,255,255,.65); text-decoration: none; font-size: 0.9rem; transition: background .15s, color .15s; border-left: 3px solid transparent; }
        .nav-item:hover, .nav-item.active { background: rgba(255,255,255,.06); color: #fff; border-left-color: var(--accent); }
        .nav-icon { font-size: 1rem; width: 20px; text-align: center; }
        .sidebar-user { padding: 16px 24px; border-top: 1px solid rgba(255,255,255,.08); font-size: 0.82rem; color: rgba(255,255,255,.5); }
        .sidebar-user strong { color: #fff; display: block; font-size: 0.88rem; }

        /* ── MAIN ── */
        .main { margin-left: var(--sidebar-w); padding: 36px; }
        .page-header { margin-bottom: 28px; }
        .page-header h1 { font-family: 'Syne', sans-serif; font-size: 1.8rem; font-weight: 800; letter-spacing: -1px; }
        .page-header p { color: var(--muted); font-size: 0.9rem; margin-top: 4px; }

        .form-card {
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 14px; overflow: hidden;
            max-width: 640px;
        }
        .form-card-header {
            background: var(--accent); padding: 22px 32px;
        }
        .form-card-header h2 {
            font-family: 'Syne', sans-serif;
            font-size: 1.15rem; font-weight: 700;
            color: #fff; margin-bottom: 2px;
        }
        .form-card-header p { font-size: 0.82rem; color: rgba(255,255,255,.75); }
        .form-card-body { padding: 32px; }

        .form-row { display: flex; gap: 18px; }
        .form-row .form-group { flex: 1; }
        .form-group { margin-bottom: 20px; }
        .form-label {
            display: block; font-size: 0.78rem; font-weight: 500;
            letter-spacing: 0.5px; text-transform: uppercase;
            color: var(--muted); margin-bottom: 7px;
        }
        .form-label .req { color: var(--accent); }
        .form-control {
            width: 100%; padding: 12px 15px;
            background: var(--paper); border: 1.5px solid var(--border);
            border-radius: 8px;
            font-family: 'DM Sans', sans-serif;
            font-size: 0.93rem; color: var(--ink);
            transition: border-color .2s, box-shadow .2s, background .2s;
            outline: none; appearance: none;
        }
        .form-control:focus {
            border-color: var(--accent); background: #fff;
            box-shadow: 0 0 0 3px rgba(232,73,15,.1);
        }
        .form-hint { font-size: 0.78rem; color: var(--muted); margin-top: 5px; }

        .form-actions {
            display: flex; gap: 12px; justify-content: flex-end;
            padding-top: 8px; border-top: 1px solid var(--border); margin-top: 8px;
        }
        .btn-submit {
            padding: 12px 28px; background: var(--accent); color: #fff;
            border: none; border-radius: 8px;
            font-family: 'Syne', sans-serif; font-size: 0.95rem; font-weight: 700;
            cursor: pointer; transition: background .2s, transform .15s;
        }
        .btn-submit:hover { background: #c73d0c; transform: translateY(-1px); }
        .btn-clear {
            padding: 12px 20px; background: transparent; color: var(--muted);
            border: 1.5px solid var(--border); border-radius: 8px;
            font-family: 'DM Sans', sans-serif; font-size: 0.92rem; font-weight: 500;
            cursor: pointer; transition: border-color .2s, color .2s;
        }
        .btn-clear:hover { border-color: var(--ink); color: var(--ink); }

        .error-inline {
            color: #b91c1c; font-size: 0.82rem;
            margin-top: 5px; display: none;
        }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <div class="sidebar-brand-name">Edu<span>QR</span></div>
            <div class="sidebar-brand-role">Admin Panel</div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section-label">Navigation</div>
            <a href="adminDashbord.jsp" class="nav-item"><span class="nav-icon">📊</span> Dashboard</a>
            <a href="reg.jsp" class="nav-item active"><span class="nav-icon">📝</span> Register Student</a>
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

    <!-- MAIN -->
    <main class="main">
        <div class="page-header">
            <h1>Register Student</h1>
            <p>Fill in the student's details to register them and generate a QR code.</p>
        </div>

        <div class="form-card">
            <div class="form-card-header">
                <h2>Student Details</h2>
                <p>All fields marked with * are required</p>
            </div>
            <div class="form-card-body">
                <form id="studentForm" method="post" action="generateQR.jsp" accept-charset="UTF-8">

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="regno">Registration No <span class="req">*</span></label>
                            <input type="text" id="regno" name="id" class="form-control"
                                   placeholder="e.g. 2200100" maxlength="20" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="branch">Branch</label>
                            <select id="branch" name="branch" class="form-control">
                                <option value="">— Select Branch —</option>
                                <option value="CSE">CSE — Computer Science</option>
                                <option value="ECE">ECE — Electronics</option>
                                <option value="ME">ME — Mechanical</option>
                                <option value="CE">CE — Civil</option>
                                <option value="EE">EE — Electrical</option>
                                <option value="OTHER">OTHER</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="name">Student Full Name <span class="req">*</span></label>
                        <input type="text" id="name" name="n" class="form-control"
                               placeholder="Enter full name" maxlength="100" required>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="mobile">Mobile Number</label>
                            <input type="text" id="mobile" name="mobile" class="form-control"
                                   placeholder="+91 XXXXXXXXXX" maxlength="20"
                                   pattern="^\+?[0-9\- ]{7,20}$">
                            <div class="form-hint">Format: +91XXXXXXXXXX or 10-digit number</div>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="email">Email Address</label>
                            <input type="email" id="email" name="email" class="form-control"
                                   placeholder="student@example.com" maxlength="60">
                        </div>
                    </div>

                    <div class="error-inline" id="errMsg">Please fill in all required fields correctly.</div>

                    <div class="form-actions">
                        <button type="button" class="btn-clear" onclick="clearForm()">Clear Form</button>
                        <button type="submit" class="btn-submit">Generate & Save QR →</button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <script>
        document.getElementById('studentForm').addEventListener('submit', function(e) {
            const regno  = document.getElementById('regno').value.trim();
            const name   = document.getElementById('name').value.trim();
            const mobile = document.getElementById('mobile').value.trim();
            const email  = document.getElementById('email').value.trim();
            const err    = document.getElementById('errMsg');

            if (!regno || !name) {
                err.textContent = 'Registration number and student name are required.';
                err.style.display = 'block';
                e.preventDefault(); return;
            }
            if (mobile && !/^\+?[0-9\- ]{7,20}$/.test(mobile)) {
                err.textContent = 'Mobile number format is invalid.';
                err.style.display = 'block';
                e.preventDefault(); return;
            }
            if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                err.textContent = 'Email address format is invalid.';
                err.style.display = 'block';
                e.preventDefault(); return;
            }
            err.style.display = 'none';
        });

        function clearForm() {
            document.getElementById('studentForm').reset();
            document.getElementById('errMsg').style.display = 'none';
        }
    </script>
</body>
</html>