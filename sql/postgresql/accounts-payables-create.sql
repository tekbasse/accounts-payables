-- accounts-payables-create.sql
--
-- @author Dekka Corp.
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id
--

CREATE TABLE qap_ap (
  id integer DEFAULT nextval ( 'qal_id' ),
  invnumber varchar(100),
  transdate date DEFAULT current_date,
  vendor_id integer,
  taxincluded bool DEFAULT 'f',
  amount numeric,
  netamount numeric,
  paid numeric,
  datepaid date,
  duedate date,
  invoice bool DEFAULT 'f',
  ordnumber varchar(100),
  curr varchar(3),
  notes text,
  employee_id integer,
  till varchar(20),
  quonumber varchar(100),
  intnotes text,
  department_id integer DEFAULT 0,
  shipvia varchar(100),
  language_code varchar(6),
  ponumber text,
  shippingpoint text,
  terms integer DEFAULT 0
);
--
create index qap_ap_id_key on qap_ap (id);
create index qap_ap_transdate_key on qap_ap (transdate);
create index qap_ap_invnumber_key on qap_ap (invnumber);
create index qap_ap_ordnumber_key on qap_ap (ordnumber);
create index qap_ap_vendor_id_key on qap_ap (vendor_id);
create index qap_ap_employee_id_key on qap_ap (employee_id);
create index qap_ap_quonumber_key on qap_ap (quonumber);

-- accounts-ledger maintenance

CREATE TRIGGER qap_del_department AFTER DELETE ON qap_ap FOR EACH ROW EXECUTE PROCEDURE qal_del_department();
-- end trigger

CREATE TRIGGER qap_del_exchangerate BEFORE DELETE ON qap_ap FOR EACH ROW EXECUTE PROCEDURE qal_del_exchangerate();
-- end trigger

CREATE TRIGGER qap_check_department AFTER INSERT OR UPDATE ON qap_ap FOR EACH ROW EXECUTE PROCEDURE qal_check_department();
-- end trigger

--
CREATE FUNCTION qap_lastcost(integer) RETURNS FLOAT AS '

DECLARE

v_cost numeric;
v_parts_id alias for $1;

BEGIN

  SELECT INTO v_cost sellprice FROM qal_invoice i
  JOIN qap_ap a ON (a.id = i.trans_id)
  WHERE i.parts_id = v_parts_id
  ORDER BY a.transdate desc
  LIMIT 1;

  IF v_cost IS NULL THEN
    v_cost := 0;
  END IF;

RETURN v_cost;
END;
' language 'plpgsql';
-- end function
--
