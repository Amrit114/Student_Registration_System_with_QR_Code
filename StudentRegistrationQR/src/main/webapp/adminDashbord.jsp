<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String user = (String)session.getAttribute("username");
    String role = (String)session.getAttribute("role");

    if (user == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch branchwise student counts
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    StringBuilder branches = new StringBuilder("[");
    StringBuilder counts   = new StringBuilder("[");
    int totalStudents = 0;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "system");

        // Total count
        PreparedStatement psTotal = con.prepareStatement("SELECT COUNT(*) FROM student_qr");
        ResultSet rsTotal = psTotal.executeQuery();
        if (rsTotal.next()) totalStudents = rsTotal.getInt(1);
        rsTotal.close(); psTotal.close();

        ps = con.prepareStatement("SELECT branch, COUNT(*) as total FROM student_qr GROUP BY branch");
        rs = ps.executeQuery();

        while (rs.next()) {
            branches.append("'").append(rs.getString("branch")).append("',");
            counts.append(rs.getInt("total")).append(",");
        }
        if (branches.length() > 1) branches.setLength(branches.length()-1);
        if (counts.length() > 1)   counts.setLength(counts.length()-1);
        branches.append("]");
        counts.append("]");
    } catch (Exception e) {
        // error handled in HTML below
    } finally {
        if (rs  != null) try { rs.close();  } catch(Exception ex) {}
        if (ps  != null) try { ps.close();  } catch(Exception ex) {}
        if (con != null) try { con.close(); } catch(Exception ex) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — EduQR</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --ink: #0d1117; --paper: #f5f0e8; --accent: #e8490f;
            --accent2: #1a56e8; --muted: #6b7280; --border: #e2d9cc;
            --sidebar-w: 240px;
        }
        body { font-family: 'DM Sans', sans-serif; background: var(--paper); }

        /* ── SIDEBAR ── */
        .sidebar {
            position: fixed; left: 0; top: 0; bottom: 0;
            width: var(--sidebar-w);
            background: var(--ink); color: #fff;
            display: flex; flex-direction: column;
            padding: 0; z-index: 50;
        }
        .sidebar-brand {
            padding: 28px 24px 20px;
            border-bottom: 1px solid rgba(255,255,255,.08);
        }
        .sidebar-brand-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.3rem; font-weight: 800;
            letter-spacing: -0.5px;
        }
        .sidebar-brand-name span { color: var(--accent); }
        .sidebar-brand-role {
            font-size: 0.72rem; color: rgba(255,255,255,.4);
            text-transform: uppercase; letter-spacing: 1.5px;
            margin-top: 4px;
        }
        .sidebar-nav { flex: 1; padding: 16px 0; overflow-y: auto; }
        .nav-section-label {
            font-size: 0.65rem; font-weight: 600;
            text-transform: uppercase; letter-spacing: 2px;
            color: rgba(255,255,255,.25);
            padding: 16px 24px 8px;
        }
        .nav-item {
            display: flex; align-items: center; gap: 12px;
            padding: 11px 24px;
            color: rgba(255,255,255,.65);
            text-decoration: none; font-size: 0.9rem;
            transition: background .15s, color .15s;
            border-left: 3px solid transparent;
        }
        .nav-item:hover, .nav-item.active {
            background: rgba(255,255,255,.06);
            color: #fff;
            border-left-color: var(--accent);
        }
        .nav-icon { font-size: 1rem; width: 20px; text-align: center; }
        .sidebar-user {
            padding: 16px 24px;
            border-top: 1px solid rgba(255,255,255,.08);
            font-size: 0.82rem; color: rgba(255,255,255,.5);
        }
        .sidebar-user strong { color: #fff; display: block; font-size: 0.88rem; }

        /* ── MAIN ── */
        .main { margin-left: var(--sidebar-w); padding: 32px 36px; }

        .page-header { margin-bottom: 32px; }
        .page-header h1 {
            font-family: 'Syne', sans-serif;
            font-size: 1.8rem; font-weight: 800;
            letter-spacing: -1px;
        }
        .page-header p { color: var(--muted); font-size: 0.9rem; margin-top: 4px; }

        /* ── STAT CARDS ── */
        .stats-row { display: flex; gap: 20px; margin-bottom: 32px; }
        .stat-card {
            flex: 1; background: #fff;
            border: 1.5px solid var(--border);
            border-radius: 12px; padding: 24px;
            position: relative; overflow: hidden;
        }
        .stat-card::before {
            content: '';
            position: absolute; top: 0; left: 0; right: 0; height: 3px;
            background: var(--accent);
        }
        .stat-card:nth-child(2)::before { background: var(--accent2); }
        .stat-card:nth-child(3)::before { background: #10b981; }
        .stat-value {
            font-family: 'Syne', sans-serif;
            font-size: 2.2rem; font-weight: 800;
            line-height: 1;
        }
        .stat-label { font-size: 0.82rem; color: var(--muted); margin-top: 8px; }

        /* ── CHART CARD ── */
        .chart-card {
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 12px; padding: 28px;
        }
        .chart-title {
            font-family: 'Syne', sans-serif;
            font-size: 1.1rem; font-weight: 700;
            margin-bottom: 24px;
        }
        .chart-wrap {
            display: flex; align-items: center; justify-content: center;
        }
        #branchChart { max-width: 320px; max-height: 320px; }

        /* Quick actions */
        .quick-actions {
            display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px;
            margin-bottom: 32px;
        }
        .action-btn {
            display: flex; align-items: center; gap: 14px;
            background: #fff; border: 1.5px solid var(--border);
            border-radius: 10px; padding: 20px;
            text-decoration: none; color: var(--ink);
            transition: border-color .2s, transform .2s, box-shadow .2s;
        }
        .action-btn:hover {
            border-color: var(--accent);
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0,0,0,.08);
        }
        .action-icon {
            font-size: 1.8rem; width: 48px; height: 48px;
            background: var(--paper); border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .action-text strong {
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem; font-weight: 700;
            display: block; margin-bottom: 2px;
        }
        .action-text span { font-size: 0.8rem; color: var(--muted); }
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
            <a href="adminDashbord.jsp" class="nav-item active">
                <span class="nav-icon">📊</span> Dashboard
            </a>
            <a href="reg.jsp" class="nav-item">
                <span class="nav-icon">📝</span> Register Student
            </a>
            <a href="manageStudent.jsp" class="nav-item">
                <span class="nav-icon">👨‍🎓</span> Manage Students
            </a>
            <a href="viewStudent.jsp" class="nav-item">
                <span class="nav-icon">🔍</span> View Students
            </a>
            <a href="printID.jsp" class="nav-item">
                <span class="nav-icon">🖨️</span> Print ID Cards
            </a>
            <a href="readQR.jsp" class="nav-item">
                <span class="nav-icon">📷</span> Scan QR Code
            </a>
        </nav>

        <div class="sidebar-user">
            <strong><%= user %></strong>
            <a href="logout.jsp" style="color:rgba(255,255,255,.4);text-decoration:none;font-size:0.8rem;">
                🚪 Logout
            </a>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main">
        <div class="page-header">
            <h1>Dashboard</h1>
            <p>Welcome back, <%= user %> — here's an overview of the system.</p>
        </div>

        <!-- STATS -->
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-value"><%= totalStudents %></div>
                <div class="stat-label">Total Students Registered</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= counts.toString().replaceAll("[\\[\\]]","").split(",").length %></div>
                <div class="stat-label">Branches Represented</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">QR</div>
                <div class="stat-label">All Students Have QR Codes</div>
            </div>
        </div>

        <!-- QUICK ACTIONS -->
        <div class="quick-actions">
            <a href="reg.jsp" class="action-btn">
                <div class="action-icon">📝</div>
                <div class="action-text">
                    <strong>Register New Student</strong>
                    <span>Add a student and generate their QR code</span>
                </div>
            </a>
            <a href="manageStudent.jsp" class="action-btn">
                <div class="action-icon">👨‍🎓</div>
                <div class="action-text">
                    <strong>Manage Students</strong>
                    <span>Edit, delete and search records</span>
                </div>
            </a>
            <a href="printID.jsp" class="action-btn">
                <div class="action-icon">🖨️</div>
                <div class="action-text">
                    <strong>Print ID Cards</strong>
                    <span>Generate and print student ID cards</span>
                </div>
            </a>
            <a href="readQR.jsp" class="action-btn">
                <div class="action-icon">📷</div>
                <div class="action-text">
                    <strong>Scan QR Code</strong>
                    <span>Camera-based QR code scanner</span>
                </div>
            </a>
        </div>

        <!-- CHART -->
        <div class="chart-card">
            <div class="chart-title">📊 Branch-wise Student Distribution</div>
            <div class="chart-wrap">
                <canvas id="branchChart"></canvas>
            </div>
        </div>
    </main>

    <script>
    const ctx = document.getElementById('branchChart').getContext('2d');
    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: <%= branches.toString() %>,
            datasets: [{
                data: <%= counts.toString() %>,
                backgroundColor: ['#e8490f','#1a56e8','#10b981','#f59e0b','#8b5cf6','#ec4899','#14b8a6'],
                borderColor: '#fff', borderWidth: 3,
                hoverBorderWidth: 0
            }]
        },
        options: {
            responsive: true,
            cutout: '60%',
            plugins: {
                legend: { position: 'right', labels: { font: { family: 'DM Sans', size: 13 } } },
                title: { display: false }
            }
        }
    });
    </script>
</body>
</html>