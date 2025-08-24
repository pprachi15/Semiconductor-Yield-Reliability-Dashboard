# 📊 Semiconductor Yield & Reliability Dashboard  

## 🔎 Project Overview  
This project focuses on analyzing **semiconductor manufacturing yield and reliability** — two of the most critical KPIs in chip production at companies like **AMD, Intel, and TSMC**.  

Using a simulated wafer dataset, I built a **Tableau dashboard** that helps engineers and managers quickly identify:  
- Where yield losses are happening  
- What shifts/tools/sensors contribute most to failures  
- How reliability trends evolve over time  

The dashboard is designed to reflect how leading semiconductor companies monitor **fab performance** to ensure efficiency, reduce defect rates, and improve time-to-market.  

---

## 🎯 Business Problem  
In semiconductor fabs, even small yield losses or reliability issues can cost millions.  

- **Yield %** measures how many wafers pass final inspection.  
- **Defect %** highlights losses caused by process variation, tool issues, or sensor failures.  
- **MTBF (Mean Time Between Failure)** shows tool reliability over time.  
- **Shift × Tool Analysis** helps identify operational inefficiencies.  

The challenge: **Provide fab managers a decision-making dashboard** to quickly see problem areas and take corrective actions.  

---

## 🛠️ Tools & Techniques  
- **Tableau** → Dashboard development, KPI visualization, interactive drilldowns  
- **Excel / SQL Preprocessing** → Cleaning and preparing wafer-level test data  
- **Reliability Engineering KPIs**:  
  - Yield %, Defect %, MTBF, Failure Rate by Hour, Effect Size by Sensor  
  - Industry-standard approach to chip reliability analysis  

---

## 📈 Key Dashboard Features  

### 1. Yield Trend  
- Tracks **daily yield %** over time  
- Helps assess fab stability and highlight days with abnormal performance  

### 2. Mean Time Between Failure (MTBF)  
- Measures reliability of fab tools  
- Trend line shows if equipment is degrading or stable  

### 3. Failure by Hour  
- Highlights failure spikes at specific hours (e.g., higher at **night shifts**)  
- Helps optimize workforce allocation and tool maintenance schedules  

### 4. Top Defect Drivers  
- Identifies sensors (e.g., **Pressure_Etch, Thickness_CMP**) contributing most to wafer failures  
- Uses effect size to quantify **impact severity**  

### 5. Tool × Shift Reliability Heatmap  
- Cross-analysis of **tools vs shifts**  
- Clearly shows **Tool-P2** with up to **25% failures at Night/Swing shifts** → actionable insight  

---

## 📊 Insights Delivered  
- Overall fab yield stable at **~92.5%**, but losses concentrated in a few problem areas  
- **Tool-P2** is the primary reliability risk, especially during **Night shift** operations  
- **Pressure_Etch** and **Thickness_CMP** sensors drive >80% of defects  
- Failures peak around **4–5 AM and 12 PM**, suggesting workforce or calibration issues  

👉 **Actionable Outcome:** Fab managers can prioritize fixing Tool-P2 and focus maintenance on Pressure_Etch + CMP sensors to recover yield.  

---

## 🚀 Why This Matters for AMD / Industry Relevance  
- AMD’s competitiveness depends on **fab yield** and **chip reliability**  
- Yield improvements = more chips per wafer = lower cost per unit  
- Reliability improvements = fewer RMAs (returns) and higher customer trust  
- This project mirrors **real-world KPI dashboards** that fabs use daily  


---

## 📸 Dashboard Preview  

<img width="1512" height="912" alt="image" src="https://github.com/user-attachments/assets/ca336c15-874e-4b76-9363-a4c2dae2a2b1" />


## 📌 Next Steps  
- Add predictive analytics (ML to forecast yield dips)  
- Automate ETL with SQL pipelines for live fab data feeds  
- Extend dashboard to **Fab vs Fab comparison (Austin vs Phoenix)**  

---

## 💡 Learning Outcomes  
- Built KPIs used in **semiconductor fabs**: Yield, Defect, MTBF, Effect Size  
- Applied **data storytelling** to highlight root causes and corrective actions  
- Learned how to align analytics with **real-world engineering problems**  

---

## 🧑‍💻 Author  
👋 Hi, I’m **Prachi**, a Strategic Data Analyst passionate about data-driven problem-solving in advanced manufacturing and technology.  

- 💼 Background: Data Analytics + Program Management (Tesla, DMV, California State University)  
- 📈 Focus: Business Intelligence, Reliability Engineering, and Data Visualization  
- 🌍 Career Goal: Work with leading companies like **AMD** to solve **mission-critical manufacturing and reliability challenges**  

---

✨ *This project is more than a dashboard, it’s a demonstration of how analytics directly supports manufacturing excellence and reliability in semiconductors.*  
 
