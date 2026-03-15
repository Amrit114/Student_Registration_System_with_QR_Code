<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
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
    <title>Print ID Cards — EduQR</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root { --ink:#0d1117; --paper:#f5f0e8; --accent:#e8490f; --accent2:#1a56e8; --muted:#6b7280; --border:#e2d9cc; --sidebar-w:240px; }
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

        /* Controls */
        .controls-panel {
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 12px; padding: 20px 24px;
            display: flex; align-items: center; gap: 16px;
            margin-bottom: 28px; flex-wrap: wrap;
        }
        .search-input { padding: 10px 14px; border: 1.5px solid var(--border); border-radius: 8px; font-family: 'DM Sans', sans-serif; font-size: 0.9rem; outline: none; transition: border-color .2s; min-width: 200px; }
        .search-input:focus { border-color: var(--accent); }
        .btn-sm { padding: 10px 18px; border: none; border-radius: 8px; font-family: 'DM Sans', sans-serif; font-size: 0.88rem; font-weight: 500; cursor: pointer; transition: all .2s; }
        .btn-accent { background: var(--accent); color: #fff; }
        .btn-accent:hover { background: #c73d0c; }
        .btn-dark { background: var(--ink); color: #fff; }
        .btn-dark:hover { background: #1c2733; }
        .btn-outline { background: transparent; border: 1.5px solid var(--border); color: var(--ink); }
        .btn-outline:hover { border-color: var(--ink); }

        /* ID Cards grid */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: 20px;
        }

        /* ID Card Design */
        .id-card {
            background: #fff;
            border: 2px solid var(--border);
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 4px 16px rgba(0,0,0,.07);
        }
        .id-card-header {
            background: var(--ink);
            padding: 14px 20px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .id-card-header-college {
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem; font-weight: 700;
            color: #fff;
        }
        .id-card-header-label {
            font-size: 0.65rem; font-weight: 600;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--accent); background: rgba(232,73,15,.15);
            padding: 4px 10px; border-radius: 4px;
        }
        .id-card-body {
            display: flex; padding: 16px 20px; gap: 16px; align-items: flex-start;
        }
        .id-card-details { flex: 1; }
        .id-field { margin-bottom: 8px; }
        .id-field-label {
            font-size: 0.65rem; font-weight: 600; text-transform: uppercase;
            letter-spacing: 1px; color: var(--muted);
        }
        .id-field-value {
            font-size: 0.9rem; color: var(--ink); font-weight: 500;
        }
        .id-name-value {
            font-family: 'Syne', sans-serif;
            font-size: 1.05rem; font-weight: 700; color: var(--ink);
        }
        .id-card-qr { flex-shrink: 0; }
        .id-card-qr img {
            width: 100px; height: 100px;
            border: 1.5px solid var(--border);
            border-radius: 6px; padding: 4px; background: #fafafa;
        }
        .id-card-footer {
            background: var(--paper);
            border-top: 1px solid var(--border);
            padding: 10px 20px;
            font-size: 0.72rem; color: var(--muted);
            text-align: center;
        }

        .empty-state { padding: 48px; text-align: center; color: var(--muted); background: #fff; border: 1.5px solid var(--border); border-radius: 12px; }

        @media print {
            .sidebar, .controls-panel { display: none !important; }
            .main { margin-left: 0; padding: 20px; }
            .id-card { break-inside: avoid; box-shadow: none; border: 1.5px solid #ccc; }
            .cards-grid { grid-template-columns: repeat(2, 1fr); gap: 12px; }
        }
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
            <a href="printID.jsp" class="nav-item active"><span class="nav-icon">🖨️</span> Print ID Cards</a>
            <a href="readQR.jsp" class="nav-item"><span class="nav-icon">📷</span> Scan QR Code</a>
        </nav>
        <div class="sidebar-user">
            <strong><%= user %></strong>
            <a href="logout.jsp" style="color:rgba(255,255,255,.4);text-decoration:none;font-size:0.8rem;">🚪 Logout</a>
        </div>
    </aside>

    <main class="main">
        <div class="page-header">
            <h1>Print ID Cards</h1>
            <p>Generate and print student identity cards with QR codes</p>
        </div>

        <div class="controls-panel no-print">
            <form method="get" style="display:flex;gap:8px;margin:0;">
                <input type="text" name="regno" class="search-input"
                       placeholder="Reg No for single card..."
                       value="<%= request.getParameter("regno") != null ? request.getParameter("regno") : "" %>">
                <button type="submit" class="btn-sm btn-accent">Generate Card</button>
            </form>
            <form method="get" style="margin:0;">
                <input type="hidden" name="showAll" value="true">
                <button type="submit" class="btn-sm btn-outline">Generate All Cards</button>
            </form>
            <button class="btn-sm btn-dark" onclick="window.print()">🖨️ Print All</button>
        </div>

        <%
            String regno   = request.getParameter("regno");
            String showAll = request.getParameter("showAll");

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "system");

                PreparedStatement ps = null;
                if (regno != null && !regno.trim().isEmpty()) {
                    ps = con.prepareStatement(
                        "SELECT s.*, u.cname FROM student_qr s JOIN qr_users u ON s.regno=u.regno WHERE s.regno=?");
                    ps.setString(1, regno);
                } else if ("true".equals(showAll)) {
                    ps = con.prepareStatement(
                        "SELECT s.*, u.cname FROM student_qr s JOIN qr_users u ON s.regno=u.regno ORDER BY s.regno");
                }

                if (ps != null) {
                    ResultSet rs = ps.executeQuery();
                    if (rs.isBeforeFirst()) {
        %>
        <div class="cards-grid">
            <% while (rs.next()) {
                String cname = rs.getString("cname");
                if (cname == null || cname.trim().isEmpty()) cname = "College Name";
            %>
            <div class="id-card">
                <div class="id-card-header">
                    <div class="id-card-header-college"><%= cname %></div>
                    <div class="id-card-header-label">Student ID</div>
                </div>
                <div class="id-card-body">
                    <div class="id-card-details">
                        <div class="id-field">
                            <div class="id-field-label">Name</div>
                            <div class="id-name-value"><%= rs.getString("name") %></div>
                        </div>
                        <div class="id-field">
                            <div class="id-field-label">Reg No</div>
                            <div class="id-field-value"><%= rs.getString("regno") %></div>
                        </div>
                        <div class="id-field">
                            <div class="id-field-label">Branch</div>
                            <div class="id-field-value"><%= rs.getString("branch") %></div>
                        </div>
                        <div class="id-field">
                            <div class="id-field-label">Mobile</div>
                            <div class="id-field-value"><%= rs.getString("mobile") != null ? rs.getString("mobile") : "—" %></div>
                        </div>
                    </div>
                    <div class="id-card-qr">
                        <img src="ShowQRImageServlet?regno=<%= rs.getString("regno") %>" alt="QR Code">
                    </div>
                </div>
                <div class="id-card-footer"><%= rs.getString("email") != null ? rs.getString("email") : "" %></div>
            </div>
            <% } %>
        </div>
        <%
                    } else {
        %>
        <div class="empty-state"><p>No student found for the given Reg No.</p></div>
        <%
                    }
                    rs.close(); ps.close();
                } else {
        %>
        <div class="empty-state">
            <p>Enter a Reg No to generate a single ID card, or click "Generate All Cards" for all students.</p>
        </div>
        <%
                }
                con.close();
            } catch (Exception e) { %>
        <div style="background:#fef2f2;border:1px solid #fecaca;color:#b91c1c;padding:14px 18px;border-radius:8px;">
            ❌ Error: <%= e.getMessage() %>
        </div>
        <% } %>
    </main>
</body>
</html>