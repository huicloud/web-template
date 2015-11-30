<%@ page language="java" pageEncoding="UTF-8"%>
<%--
<script type="text/javascript">
$(function(){
	
	new DataStore({ //投资评级
		dataType: "json",
	    serviceUrl: "/forecasts/yzxtzpj"
	}).query({
		obj: currCode
	}).then(function(result) {
		var data = result[currCode];
		var pre = data[0].zhengTiPinJi;
		var curr = data[1].zhengTiPinJi;
		
		$("#tzpjDiv").addClass("iqktop" + getPinJiNum(curr));
		$("#tzpjnextDiv").addClass("iqknnder" + getPinJiNum(pre));
	});
	
});
</script>

<div class="sim-box investment-grade">
    <h3>投资评级</h3>
    <div class="sim-box-content">
        <div class="situation">
            <div class="iqktop">
                <div id="tzpjDiv">
                    <div class="up-pos">
                        <div class="up-bg"><span>本期评级</span></div>
                    </div>
                </div>
            </div>
            <div class="iqknnder">
                <div id="tzpjnextDiv">
                    <div class="up-pos">
                        <div class="up-bg"><span>上一期评级</span></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
--%>