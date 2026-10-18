# 💰 Personal Finance Dashboard (PostgreSQL & Power BI Project)

> An end-to-end personal finance analytics project built with **PostgreSQL, Power BI, DAX, SVG, and Figma**. The dashboard brings income, expenses, savings, transaction activity, and audit history together in one interactive report.

## 🧩 Project Overview

This project explores how a personal finance system can be monitored through an interactive analytics dashboard. PostgreSQL stores the financial transactions and maintains audit and archive records, while Power BI connects to the database through **DirectQuery** to visualize financial performance and transaction history.

The interface is designed in **Figma**, with a consistent visual style, custom navigation, slicers, dynamic text cards, and SVG-based visuals.

📊 **Project goals**
- Track income, expenses, balance, and monthly savings.
- Understand spending patterns by month, category, and transaction type.
- Compare income and expenses over time.
- Monitor transaction changes, deletions, restorations, and archived records.
- Demonstrate how PostgreSQL audit logic can be explored through Power BI.

## ⚙️ Tech Stack

| Tool | Purpose |
|------|---------|
| 🗃️ **PostgreSQL** | Financial data storage, relational tables, constraints, triggers, functions, audit logging, archive and restore logic |
| 📊 **Power BI** | Interactive dashboards, KPI cards, charts, tables, slicers, and report navigation |
| 🧮 **DAX** | Measures, dynamic titles, KPI comparisons, conditional messages, and SVG visuals |
| 🎨 **Figma** | Dashboard UI/UX, navigation elements, and custom visual design |
| 🔌 **DirectQuery** | Connects Power BI visuals to PostgreSQL data |
| 🐙 **GitHub** | Version control and project documentation |

## 🗄️ Database Overview

The PostgreSQL database is organized around these tables:

| Table | Purpose |
|-------|---------|
| `source` | Defines source types used to classify financial records |
| `category` | Stores transaction categories and their source relationship |
| `finance` | Main financial transaction table, including date, amount, type, note, source, and category |
| `audit_log` | Records transaction actions and tracked old/new values |
| `archive` | Stores deleted transaction records for audit and recovery workflows |

### Database features

- Primary and foreign key relationships.
- Check constraints for valid amounts and transaction types.
- Trigger-based audit logging for updates and deletions.
- Archiving of deleted finance records.
- A restore workflow for returning archived transactions to the finance table.
- Threshold logic that raises a notice when monthly expenses reach the configured limit.
- Historical audit timestamps used for demonstration and reporting. Any simulated audit history should be understood as sample data rather than proof of real-world event timing.

## 📈 Dashboard Pages

The report contains five pages with shared navigation, slicers, a refresh timestamp, and a clear-all-slicers control.

### 🏠 Page 1: Home
- Personalized landing page.
- Custom navigation to the report sections.
- Figma-designed interface.

### 📊 Page 2: Overview
**Purpose:** Provide a quick view of the overall financial position.

- KPIs: Total Income and Total Expense.
- Current-month spending tracker with a ₹20,000 reference limit.
- Balance card showing income minus expenses.
- Average Monthly Expense and Average Monthly Income.
- Saving Rate and Saving by Month.
- Monthly Income vs Expense chart with a visual-specific year selector.
- Refresh date and time.

### 💸 Page 3: Expense Analysis
**Purpose:** Investigate expense patterns and identify major spending categories.

- Highest Expense Transaction and Average Expense Transaction.
- Top 5 Expense Categories.
- Dynamic message highlighting the previous month's leading expense category and its share.
- Donut charts for total expense and number of expense transactions, split by Cash and Accounts.
- Monthly Expense vs Average Expense comparison.
- Category-by-month matrix.
- Expense by Category chart.

### 📈 Page 4: Income Analysis
**Purpose:** Understand income sources and savings performance over time.

- Dynamic message showing the highest-saving month of the year.
- Total Income and current-versus-previous-year income comparison.
- Net Saving and Saving Rate.
- Average Monthly Income.
- Monthly Saving vs Bonus vs Salary analysis.
- Net Savings Over Time.
- Income by Category.
- Monthly income compared with the average for the selected period.

### 🧾 Page 5: Transaction & Audit Analysis
**Purpose:** Monitor transaction activity and explore audit and archive records.

- Total, Cash, and Accounts transaction KPIs.
- Dynamic message comparing deletion and restoration activity.
- SVG progress bars for DELETE, RESTORE, and UPDATE audit activity.
- Transaction Volume Over Time.
- Summary of the most frequent correction types, including amount, category, transaction date, and transaction type.
- Cash vs Accounts transaction visuals.
- Archived Transactions table.
- Audit Activity by Action across year and month.

## 🔄 Refresh and Interactivity

- Power BI uses PostgreSQL **DirectQuery** for report data.
- The report is configured for a **59-second page refresh**.
- A refresh date/time indicator is displayed on the pages.
- A clear-all-slicers control is available throughout the report.
- Some slicers are intentionally configured to affect only specific visuals.
- DAX measures power dynamic messages, KPI comparisons, and custom SVG-based progress visuals.

Actual data freshness depends on the Power BI report settings, the DirectQuery connection, and the environment in which the report is running.

## 🧠 Key Skills Demonstrated

- PostgreSQL table design and relational constraints
- SQL triggers and functions
- Audit logging and old/new value tracking
- Archive and restore workflows
- Power BI DirectQuery
- DAX measures and dynamic text
- SVG visuals created through DAX
- KPI cards, donut charts, bar charts, line charts, matrices, and tooltips
- Slicer interactions and report navigation
- Figma-based dashboard UI/UX design
- Financial and transaction audit analysis

## 🚀 How to Explore the Project

1. Review the PostgreSQL schema and SQL scripts included in the repository.
2. Set up the database and load the project data.
3. Configure the PostgreSQL connection used by the Power BI report.
4. Open the Power BI report in Power BI Desktop.
5. Check the report pages, slicer interactions, DAX measures, and audit analysis.

> **Note:** Database scripts, data files, and the Power BI report must be available in the repository or configured locally for these steps to work. Connection credentials and other private settings should be configured on your own machine rather than committed to GitHub.

## 👨‍💻 About Me

Hi, I'm **Gaurav Khanna**, a Data Analyst interested in turning data into clear, useful insights through SQL, data modeling, and interactive dashboards.

## 🤝 Connect with Me

🌐 **Portfolio:** [gouravkhanna03.github.io/portfolio](https://gouravkhanna03.github.io/portfolio/)  
💼 **LinkedIn:** [Gaurav Khanna](https://www.linkedin.com/in/gauravkhanna03/)  
📧 **Email:** [gouravkhanna03@gmail.com](mailto:gouravkhanna03@gmail.com)

## 🔖 Keywords

`Personal Finance Dashboard` `Power BI` `PostgreSQL` `DirectQuery` `DAX` `Figma` `Financial Analysis` `Expense Analysis` `Income Analysis` `Savings Analysis` `SQL Triggers` `Audit Logging` `Archive and Restore` `Data Analytics`
