<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EduQR — Student Data & QR Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --ink:    #0d1117;
            --paper:  #f5f0e8;
            --accent: #e8490f;
            --accent2:#1a56e8;
            --muted:  #6b7280;
            --card:   #ffffff;
            --border: #e2d9cc;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--paper);
            color: var(--ink);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* ── NOISE TEXTURE OVERLAY ── */
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.04'/%3E%3C/svg%3E");
            pointer-events: none; z-index: 0;
        }

        /* ── HEADER BAR ── */
        .topbar {
            position: fixed; top: 0; left: 0; right: 0; z-index: 100;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 48px; height: 64px;
            background: var(--ink);
        }
        .topbar-brand {
            font-family: 'Syne', sans-serif;
            font-size: 1.2rem; font-weight: 800;
            color: #fff; letter-spacing: -0.5px;
        }
        .topbar-brand span { color: var(--accent); }
        .topbar-nav a {
            font-size: 0.85rem; font-weight: 500;
            color: rgba(255,255,255,0.6);
            text-decoration: none; margin-left: 28px;
            transition: color .2s;
        }
        .topbar-nav a:hover { color: #fff; }

        /* ── HERO ── */
        .hero {
            position: relative; z-index: 1;
            padding: 160px 48px 80px;
            display: grid; grid-template-columns: 1fr 420px; gap: 48px;
            max-width: 1200px; margin: 0 auto; align-items: center;
        }
        .hero-label {
            display: inline-flex; align-items: center; gap: 8px;
            background: var(--accent); color: #fff;
            font-family: 'Syne', sans-serif; font-size: 0.7rem;
            font-weight: 700; letter-spacing: 2px; text-transform: uppercase;
            padding: 6px 14px; border-radius: 2px;
            margin-bottom: 24px;
        }
        .hero-title {
            font-family: 'Syne', sans-serif;
            font-size: clamp(2.8rem, 5vw, 4.5rem);
            font-weight: 800; line-height: 1.02;
            letter-spacing: -2px;
            margin-bottom: 24px;
        }
        .hero-title em { font-style: normal; color: var(--accent); }
        .hero-subtitle {
            font-size: 1.05rem; font-weight: 300;
            color: var(--muted); line-height: 1.7;
            max-width: 480px; margin-bottom: 40px;
        }

        /* ── ROLE CARDS ── */
        .role-cards {
            display: flex; flex-direction: column; gap: 16px;
        }
        .role-card {
            background: var(--card);
            border: 1.5px solid var(--border);
            border-radius: 12px;
            padding: 28px 32px;
            position: relative; overflow: hidden;
            transition: transform .25s, box-shadow .25s, border-color .25s;
        }
        .role-card::before {
            content: '';
            position: absolute; left: 0; top: 0; bottom: 0; width: 4px;
            background: var(--accent);
            transform: scaleY(0); transform-origin: bottom;
            transition: transform .3s;
        }
        .role-card:hover { transform: translateY(-3px); box-shadow: 0 12px 40px rgba(0,0,0,.1); border-color: var(--accent); }
        .role-card:hover::before { transform: scaleY(1); }
        .role-card.admin::before { background: var(--accent2); }
        .role-card.admin:hover { border-color: var(--accent2); }

        .role-icon {
            font-size: 2rem; margin-bottom: 12px; display: block;
        }
        .role-name {
            font-family: 'Syne', sans-serif;
            font-size: 1.2rem; font-weight: 700;
            margin-bottom: 6px;
        }
        .role-desc {
            font-size: 0.85rem; color: var(--muted);
            margin-bottom: 20px; line-height: 1.5;
        }
        .role-actions { display: flex; gap: 10px; }
        .btn {
            display: inline-block;
            padding: 10px 22px; border-radius: 6px;
            font-family: 'DM Sans', sans-serif;
            font-size: 0.9rem; font-weight: 500;
            text-decoration: none; cursor: pointer;
            border: none; transition: all .2s;
        }
        .btn-primary {
            background: var(--accent); color: #fff;
        }
        .btn-primary:hover { background: #c73d0c; transform: translateY(-1px); }
        .btn-secondary {
            background: transparent; color: var(--ink);
            border: 1.5px solid var(--border);
        }
        .btn-secondary:hover { border-color: var(--ink); background: var(--ink); color: #fff; }
        .btn-admin { background: var(--accent2); }
        .btn-admin:hover { background: #1345c5; }

        /* ── STATS STRIP ── */
        .stats {
            position: relative; z-index: 1;
            max-width: 1200px; margin: 0 auto;
            padding: 0 48px 80px;
            display: flex; gap: 32px;
        }
        .stat {
            flex: 1;
            background: var(--ink); color: #fff;
            border-radius: 10px;
            padding: 28px 32px;
        }
        .stat-number {
            font-family: 'Syne', sans-serif;
            font-size: 2.5rem; font-weight: 800;
            color: var(--accent); line-height: 1;
            margin-bottom: 8px;
        }
        .stat-label { font-size: 0.85rem; color: rgba(255,255,255,0.5); }

        /* ── FEATURES ── */
        .features {
            position: relative; z-index: 1;
            max-width: 1200px; margin: 0 auto;
            padding: 0 48px 100px;
        }
        .section-heading {
            font-family: 'Syne', sans-serif;
            font-size: 2rem; font-weight: 700;
            letter-spacing: -1px; margin-bottom: 32px;
        }
        .features-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;
        }
        .feature-item {
            padding: 24px;
            background: var(--card);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            transition: transform .2s;
        }
        .feature-item:hover { transform: translateY(-4px); }
        .feature-emoji { font-size: 1.8rem; margin-bottom: 12px; }
        .feature-title { font-family: 'Syne', sans-serif; font-weight: 700; margin-bottom: 8px; }
        .feature-text { font-size: 0.875rem; color: var(--muted); line-height: 1.6; }

        /* ── FOOTER ── */
        .footer {
            position: relative; z-index: 1;
            background: var(--ink); color: rgba(255,255,255,0.5);
            text-align: center; padding: 24px;
            font-size: 0.8rem;
        }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(24px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .hero-label  { animation: fadeUp .5s ease both; }
        .hero-title  { animation: fadeUp .5s .1s ease both; }
        .hero-subtitle { animation: fadeUp .5s .2s ease both; }
        .role-cards  { animation: fadeUp .5s .3s ease both; }

        @media (max-width: 900px) {
            .hero { grid-template-columns: 1fr; padding-top: 120px; }
            .stats { flex-direction: column; }
            .features-grid { grid-template-columns: 1fr 1fr; }
        }
    </style>
</head>
<body>

    <!-- TOP BAR -->
    <nav class="topbar">
        <div class="topbar-brand">Edu<span>QR</span></div>
        <div class="topbar-nav">
            <a href="login.jsp">Login</a>
            <a href="register.jsp">Register</a>
        </div>
    </nav>

    <!-- HERO -->
    <section class="hero">
        <div>
            <div class="hero-label">🎓 B.Tech Computer Science Project</div>
            <h1 class="hero-title">
                Student Data<br>& <em>QR Code</em><br>Management
            </h1>
            <p class="hero-subtitle">
                A complete system to register students, generate unique QR codes,
                manage records, print ID cards, and scan QR codes — all in one place.
            </p>
        </div>

        <div class="role-cards">
            <!-- Student Card -->
            <div class="role-card student">
                <span class="role-icon">👨‍🎓</span>
                <div class="role-name">Student Portal</div>
                <div class="role-desc">Access your profile, view your QR code, and check your details.</div>
                <div class="role-actions">
                    <a href="login.jsp" class="btn btn-primary">Login</a>
                    <a href="register.jsp" class="btn btn-secondary">Register</a>
                </div>
            </div>

            <!-- Admin Card -->
            <div class="role-card admin">
                <span class="role-icon">🛡️</span>
                <div class="role-name">Admin Portal</div>
                <div class="role-desc">Manage all students, generate QR codes, print ID cards & view analytics.</div>
                <div class="role-actions">
                    <a href="login.jsp" class="btn btn-primary btn-admin">Admin Login</a>
                </div>
            </div>
        </div>
    </section>

    <!-- STATS -->
    <section class="stats">
        <div class="stat">
            <div class="stat-number">QR</div>
            <div class="stat-label">Unique code for every student</div>
        </div>
        <div class="stat">
            <div class="stat-number">ID</div>
            <div class="stat-label">Printable ID cards with one click</div>
        </div>
        <div class="stat">
            <div class="stat-number">📊</div>
            <div class="stat-label">Branch-wise analytics dashboard</div>
        </div>
        <div class="stat">
            <div class="stat-number">📷</div>
            <div class="stat-label">Live camera QR scanning</div>
        </div>
    </section>

    <!-- FEATURES -->
    <section class="features">
        <h2 class="section-heading">Everything You Need</h2>
        <div class="features-grid">
            <div class="feature-item">
                <div class="feature-emoji">📝</div>
                <div class="feature-title">Student Registration</div>
                <div class="feature-text">Register students with name, branch, mobile, email and auto-generate a QR code stored in the database.</div>
            </div>
            <div class="feature-item">
                <div class="feature-emoji">🔍</div>
                <div class="feature-title">Search & Manage</div>
                <div class="feature-text">Search by registration number, edit details, and delete records with instant confirmation.</div>
            </div>
            <div class="feature-item">
                <div class="feature-emoji">🖨️</div>
                <div class="feature-title">Print ID Cards</div>
                <div class="feature-text">Generate professional ID cards with QR codes for individual students or the entire batch.</div>
            </div>
            <div class="feature-item">
                <div class="feature-emoji">📷</div>
                <div class="feature-title">QR Scanner</div>
                <div class="feature-text">Scan any student's QR code with your camera and instantly view their complete details with voice readout.</div>
            </div>
            <div class="feature-item">
                <div class="feature-emoji">📊</div>
                <div class="feature-title">Analytics Dashboard</div>
                <div class="feature-text">Visual pie chart showing branch-wise student distribution for quick administrative insights.</div>
            </div>
            <div class="feature-item">
                <div class="feature-emoji">🔒</div>
                <div class="feature-title">Role-Based Access</div>
                <div class="feature-text">Separate login flows for students and administrators with session-based authentication.</div>
            </div>
        </div>
    </section>

    <footer class="footer">
        &copy; 2024 EduQR — Student Data & QR Management System &nbsp;|&nbsp; B.Tech Computer Science Project
    </footer>

</body>
</html>