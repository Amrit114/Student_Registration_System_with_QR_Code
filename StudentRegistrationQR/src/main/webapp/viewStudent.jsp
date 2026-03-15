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
    <title>View Students — EduQR</title>
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

        .controls-bar { background: #fff; border: 1.5px solid var(--border); border-radius: 10px; padding: 16px 20px; display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
        .search-input { padding: 10px 14px; border: 1.5px solid var(--border); border-radius: 8px; font-family: 'DM Sans', sans-serif; font-size: 0.9rem; outline: none; transition: border-color .2s; flex: 1; min-width: 160px; }
        .search-input:focus { border-color: var(--accent); }
        .btn-sm { padding: 10px 18px; border: none; border-radius: 8px; font-family: 'DM Sans', sans-serif; font-size: 0.88rem; font-weight: 500; cursor: pointer; transition: all .2s; }
        .btn-accent { background: var(--accent); color: #fff; }
        .btn-accent:hover { background: #c73d0c; }
        .btn-dark { background: var(--ink); color: #fff; }
        .btn-dark:hover { background: #1c2733; }
        .btn-outline { background: transparent; border: 1.5px solid var(--border); color: var(--ink); }
        .btn-outline:hover { border-color: var(--ink); }

        .table-card { background: #fff; border: 1.5px solid var(--border); border-radius: 12px; overflow: hidden; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: var(--ink); }
        thead th { padding: 14px 16px; font-family: 'Syne', sans-serif; font-size: 0.78rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: rgba(255,255,255,.7); text-align: left; }
        tbody tr { border-bottom: 1px solid var(--border); transition: background .15s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #fafaf8; }
        tbody td { padding: 14px 16px; font-size: 0.88rem; color: var(--ink); vertical-align: middle; }
        .qr-thumb { cursor: pointer; transition: transform .2s; border: 1px solid var(--border); border-radius: 4px; padding: 3px; background: #fff; }
        .qr-thumb:hover { transform: scale(1.2); }
        .empty-state { padding: 48px; text-align: center; color: var(--muted); }

        .qr-modal { display: none; position: fixed; inset: 0; z-index: 1000; background: rgba(0,0,0,.8); justify-content: center; align-items: center; }
        .qr-modal.open { display: flex; }
        .qr-modal img { max-width: 280px; max-height: 280px; border: 6px solid #fff; border-radius: 12px; }

        @media print {
            .sidebar, .controls-bar { display: none !important; }
            .main { margin-left: 0; }
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
            <a href="viewStudent.jsp" class="nav-item active"><span class="nav-icon">🔍</span> View Students</a>
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
            <h1>View Students</h1>
            <p>Browse all student records with their QR codes</p>
        </div>

        <div class="controls-bar no-print">
            <form method="get" style="display:flex;gap:8px;flex:1;margin:0;">
                <input type="text" name="regno" class="search-input"
                       placeholder="Search by Reg No..."
                       value="<%= request.getParameter("regno") != null ? request.getParameter("regno") : "" %>">
                <button type="submit" class="btn-sm btn-accent">🔍 Search</button>
            </form>
            <form method="get" style="margin:0;">
                <input type="hidden" name="showAll" value="true">
                <button type="submit" class="btn-sm btn-outline">Show All</button>
            </form>
            <button class="btn-sm btn-dark" onclick="window.print()">🖨️ Print</button>
        </div>

        <%
            String regno   = request.getParameter("regno");
            String showAll = request.getParameter("showAll");

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "system");

                PreparedStatement ps = null;
                if (regno != null && !regno.trim().isEmpty()) {
                    ps = con.prepareStatement("SELECT * FROM student_qr WHERE regno=?");
                    ps.setString(1, regno);
                } else if ("true".equals(showAll)) {
                    ps = con.prepareStatement("SELECT * FROM student_qr ORDER BY regno");
                }

                if (ps != null) {
                    ResultSet rs = ps.executeQuery();
        %>
        <div class="table-card">
            <% if (rs.isBeforeFirst()) { %>
            <table>
                <thead>
                    <tr>
                        <th>Reg No</th><th>Name</th><th>Branch</th>
                        <th>Mobile</th><th>Email</th><th>QR Code</th>
                    </tr>
                </thead>
                <tbody>
                    <% while (rs.next()) { %>
                    <tr>
                        <td><strong><%= rs.getString("regno") %></strong></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("branch") %></td>
                        <td><%= rs.getString("mobile") != null ? rs.getString("mobile") : "—" %></td>
                        <td><%= rs.getString("email")  != null ? rs.getString("email")  : "—" %></td>
                        <td>
                            <img src="ShowQRImageServlet?regno=<%= rs.getString("regno") %>"
                                 class="qr-thumb" width="60" onclick="openQR(this.src)">
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } else { %>
            <div class="empty-state"><p>No students found. Use search or click "Show All".</p></div>
            <% } %>
        </div>
        <%
                    rs.close(); ps.close();
                } else {
        %>
        <div class="table-card">
            <div class="empty-state"><p>Use the search box or click "Show All Students" to view records.</p></div>
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

    <div id="qrModal" class="qr-modal" onclick="closeQR()">
        <img id="qrModalImg" src="" alt="QR Code">
    </div>
    <script>
        function openQR(src) { document.getElementById('qrModal').classList.add('open'); document.getElementById('qrModalImg').src = src; }
        function closeQR() { document.getElementById('qrModal').classList.remove('open'); }
    </script>
</body>
</html>