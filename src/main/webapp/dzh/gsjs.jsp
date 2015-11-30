<%@ page language="java" pageEncoding="UTF-8"%>

<script type="text/javascript">

$(function(){

	var gsjs = $("div.stock-company-profile");
	new DataStore({
		//dataType: "json",
        serviceUrl: "/f10/gsgk"
    }).query({obj: currCode}).then(function(data) {
        var d = data[0];
        gsjs.find(".gsmc").html(d.gsmc).end().find(".ywqc").html(d.ywqc).end()
        .find(".zcdz").html(d.zcdz).end().find(".bgdz").html(d.bgdz).end()
        .find(".ssqy").html(d.ssqy).end().find(".sshy").html(d.sshy).end()
        .find(".gswz").html(d.gswz).end().find(".dzxx").html(d.dzxx).end()
        .find(".ssrq").html(d.ssrq).end().find(".zgrq").html(d.zgrq).end()
        .find(".fxl").html(d.fxl+"万股").end().find(".fxj").html(d.fxj).end()
        .find(".srkpj").html(d.srkpj).end().find(".sstjr").html(d.sstjr).end()
        .find(".zcxs").html(d.zcxs).end().find(".kjsws").html(d.kjsws).end()
        .find(".frdb").html(d.frdb).end().find(".dsz").html(d.dsz).end()
        .find(".dm").html(d.dm).end().find(".zqdb").html(d.zqdb).end()
        .find(".dh").html(d.dh).end().find(".cz").html(d.cz).end()
        .find(".zyfw").html(d.zyfw).end().find(".gsjs").html(d.gsjs).end();
    });
	
});

</script>

<div class="content-box stock-company-profile">
    <ul class="tab-style-c">
        <li class="active"><a href="javascript:void(0);">公司介绍</a></li>
    </ul>
    <div class="stock-company-profile-content">
        <table width="100%" class="table-style-e">
          <colgroup>
	          <col width="13%">
	          <col width="37%">
	          <col width="13%">
	          <col width="37%">
          </colgroup>
          <tbody>
            <tr>
              <th class="graybg tar">公司名称:</th>
              <td class="gsmc"></td>
              <th class="graybg tar">英文名称:</th>
              <td class="ywqc"></td>
            </tr>
            <tr>
              <th class="graybg tar">注册地址:</th>
              <td class="zcdz"></td>
              <th class="graybg tar">办公地址:</th>
              <td class="bgdz"></td>
            </tr>
            <tr>
              <th class="graybg tar">所属区域:</th>
              <td class="ssqy"></td>
              <th class="graybg tar">所属行业:</th>
              <td class="sshy"></td>
            </tr>
            <tr>
              <th class="graybg tar">公司网址:</th>
              <td class="gswz"></td>
              <th class="graybg tar">电子邮箱:</th>
              <td class="dzxx"></td>
            </tr>
            <tr>
              <th class="graybg tar">上市日期:</th>
              <td class="ssrq"></td>
              <th class="graybg tar">招股日期:</th>
              <td class="zgrq"></td>
            </tr>
            <tr>
              <th class="graybg tar">发行量:</th>
              <td class="fxl"></td>
              <th class="graybg tar">发行价:</th>
              <td class="fxj"></td>
            </tr>
            <tr>
              <th class="graybg tar">首日开盘价:</th>
              <td class="srkpj"></td>
              <th class="graybg tar">上市推荐人:</th>
              <td class="sstjr"></td>
            </tr>
            <tr>
              <th class="graybg tar">主承销商:</th>
              <td class="zcxs"></td>
              <th class="graybg tar">会计事务所:</th>
              <td class="kjsws"></th>
            </tr>
            <tr>
              <th class="graybg tar">法人代表:</th>
              <td class="frdb"></td>
              <th class="graybg tar">董 事 长:</th>
              <td class="dsz"></td>
            </tr>
            <tr>
              <th class="graybg tar">董 秘:</th>
              <td class="dm"></td>
              <th class="graybg tar">证券代表:</th>
              <td class="zqdb"></td>
            </tr>
            <tr>
              <th class="graybg tar">电话:</th>
              <td class="dh"></td>
              <th class="graybg tar">传真:</th>
              <td class="cz"></td>
            </tr>
            <tr>
              <th class="graybg tar">主营范围:</th>
              <td class="zyfw" colspan="3"></td>
            </tr>
            <tr>
              <th class="graybg tar">公司简史:</th>
              <td class="gsjs" colspan="3"></td>
            </tr>
          </tbody>
        </table>
    </div>
</div>