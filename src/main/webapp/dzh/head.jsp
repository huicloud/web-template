<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" pageEncoding="UTF-8"%>

<!-- common css -->
<link type="text/css" media="all" rel="stylesheet" href="<c:url value="/dzh/css/base.css"/>" />
<link type="text/css" media="all" rel="stylesheet" href="<c:url value="/dzh/css/common.css"/>" />
<link type="text/css" media="all" rel="stylesheet" href="<c:url value="/dzh/css/stock.css"/>" />
<link type="text/css" media="all" rel="stylesheet" href="<c:url value="/dzh/css/jquery-ui.min.css"/>" />


<!-- common js -->
<script type="text/javascript" src="<c:url value="/dzh/js/jquery.js"/>"></script>
<script type="text/javascript" src="<c:url value="/dzh/js/jquery.tools.js"/>"></script> 
<script type="text/javascript" src="<c:url value="/dzh/js/jquery-ui.min.js"/>"></script> 
<script type="text/javascript" src="<c:url value="/dzh/js/common.js"/>"></script>
<script type="text/javascript" src="<c:url value="/dzh/js/polyfill.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/dzh/js/datastore.all.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/dzh/js/stupidtable.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/dzh/js/jPages.min.js"/>"></script>

<%
	String stockCode = request.getParameter("stockCode");
	if (stockCode != null) {
		session.setAttribute("stockCode", stockCode);
	}
%>

<script type="text/javascript">

var rootPath = "${pageContext.request.contextPath}";
var currCode = "<%=session.getAttribute("stockCode")%>";
var yundzhToken = "<%=session.getAttribute("yundzhToken")%>";
if(!currCode || currCode == "null") currCode = "SH600000";

var url = "ws://10.15.144.101/ws";
//var url = "ws://v2.yundzh.com/ws";
if (!window.WebSocket) {
	DataStore.pause = false;
	DataStore.dataType = "json";
//	url = "http://v2.yundzh.com";
	url = "http://10.15.144.101";
}
DataStore.address = url;
DataStore.token = yundzhToken;

var mystockurl = "http://180.168.15.77:10010/91bee";
</script>
