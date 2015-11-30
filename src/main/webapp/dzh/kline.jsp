<%@ page language="java" pageEncoding="UTF-8"%>

<script type="text/javascript">

$(function(){
	
	var chart = new Chart($("#kline"), {
        dataProvider: new ChartDataProvider(currCode)
    });
	
});

</script>

<!-- kline -->
<div id="kline" class="kline"></div>
<!-- kline -->