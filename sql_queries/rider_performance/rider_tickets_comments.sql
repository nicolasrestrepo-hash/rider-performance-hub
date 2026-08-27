DECLARE dInf DATE DEFAULT current_date()-20;
DECLARE dSup DATE DEFAULT current_date();

WITH orders AS (
  SELECT
    date,
    hour,
    rider_id,
    compliance_segment,
    order_code,
    name,
    franchise_name,
    vertical,
    city_name,
    cancellation_reason,
    reject_message,
    order_value,
    metodo_pago,
    is_pin_validation,
    batch,
    last_state_anterior
  FROM `peya-argentina.automated_tables_reports.DETALLE_ORDENES_rider_Performance`
  WHERE date >= dInf AND date < dSup
  GROUP BY ALL
),

staffing AS (
  SELECT
    date,
    rider_id,
    city,
    zone_name,
    compliance_segment,
    batch,
    segmentos,
    grade_ponderado,
    tenure_buckets
  FROM `peya-argentina.automated_tables_reports.Staffing_Rider_Performance_AR`
  WHERE date >= dInf AND date < dSup
  GROUP BY ALL
),

-- Extraemos y limpiamos el comentario del formulario
rider_comments AS (
  SELECT 
    m.work_item_id,
    STRING_AGG(
      IF(msg.is_agent = FALSE, msg.content, NULL), 
      ' | ' ORDER BY msg.created_at ASC
    ) AS full_raw_comment,
    
    STRING_AGG(
      IF(
        msg.is_agent = FALSE, 
        COALESCE(
          REGEXP_EXTRACT(msg.content, r'Comentarios del rider:\s*(.*)'), 
          msg.content
        ), 
        NULL
      ), 
      ' | ' ORDER BY msg.created_at ASC
    ) AS rider_chat_comment
  FROM `peya-data-origins-pro.cl_gcc_service.herocare_non_live_message_history` AS m,
  UNNEST(m.message_history) AS msg
  WHERE m.global_entity_id = 'PY_AR'
    AND msg.content IS NOT NULL
  GROUP BY m.work_item_id
)

SELECT
  DATE(t.work_item_created_at, timezone) AS created_date,
  DATETIME(t.work_item_created_at, timezone) AS created_at,
  t.customer_id AS rider_id,
  s.city,
  s.zone_name,
  s.compliance_segment,
  s.batch,
  s.segmentos,
  s.grade_ponderado,
  s.tenure_buckets,
  t.case_id,
  t.work_item_id,
  t.contact_reason_l1,
  t.contact_reason_l2,
  t.contact_reason_l3,
  t.local_contact_reason,
  t.order_id,
  o.date AS order_created_date,
  o.reject_message,
  o.metodo_pago,
  o.franchise_name,
  o.vertical,
  o.name AS partner_name,
  rc.rider_chat_comment, 
  rc.full_raw_comment    
FROM `peya-data-origins-pro.cl_gcc_service.pandacare_work_items` AS t
LEFT JOIN orders AS o 
  ON o.order_code = CAST(t.order_id AS STRING)
LEFT JOIN staffing AS s 
  ON SAFE_CAST(s.rider_id AS STRING) = SAFE_CAST(t.customer_id AS STRING) 
  AND s.date = DATE(t.work_item_created_at, timezone)
LEFT JOIN rider_comments AS rc 
  ON rc.work_item_id = t.work_item_id 
WHERE t.global_entity_id = 'PY_AR'
  AND t.created_date BETWEEN dInf-1 AND dSup+1
  AND t.created_date_localtime >= dInf
  AND t.created_date_localtime < dSup
  AND DATETIME(t.work_item_created_at, timezone) >= dInf
  AND DATETIME(t.work_item_created_at, timezone) < dSup
  AND t.stakeholder = 'Rider'
QUALIFY ROW_NUMBER() OVER (PARTITION BY t.case_id ORDER BY DATETIME(t.work_item_created_at, timezone) ASC) = 1;
