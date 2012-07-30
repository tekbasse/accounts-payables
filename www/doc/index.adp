<master>
  <property name="title">@package_instance_name@</property>
 <p>
  Accounts Payables provides services to other packages and provides a basic UI for directly managing accounts payables.
 </p>
<h3>
 Features
</h3>
<h4>Converted:</h4>
<ul><li>
Data model for Postgresql.
</li><li>
Num2text in SL, lc_number_to_text
</li></ul>
<h4>Planned:</h4>
 <p>
Basic posting/editing via web and service (and/or callback?), and modifying the progress of an order.
 </p>
<h3>
notes</h3>
<p>see accounts-ledger documentation for related information and overall project status</p>
<pre>
sql-ledger        package-key  table name

&lt;table_name&gt;        qal_&lt;table_name&gt;


</pre><p>
Need to add package_key to data model.
</p><h3>
porting notes and guidelines
</h3><p>

</p><p>
Any functions dependent on accounts payable (AP) are moved to this package. When something is dependent on two or more accounting packages, it is moved into the "full accounting features" accounts-desk package.

</p>
<h3>
functions and procedures
</h3><p>
lc_number_to_text proc is made from the the SL Num2text procedure which has localized cases in the locale directories, and the default Num2text.pm in sql-ledger/SL/
</p>
<h3>
SQL
</h3><p>
The Oracle SQL will be added after the PG SQL has settled a bit.
</p><p>Some of the SQL has been changed to the OpenACS standards. See http://openacs.org/doc/current/eng-standards-plsql.html and http://openacs.org/wiki
</p><pre>
for Postgresql:

INT changed to INTEGER
some of the TEXT types were changed to VARCHAR so that they get indexed
FLOAT changed to NUMERIC
</pre>

