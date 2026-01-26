import{d as de,a as J,c as dt,p as pt,b as gt,u as G,e as ne,r as g,j as t,B as mt,S as Me,f as We,I as ut,T as Qe,g as Ge,h as ht,i as tt,D as yt,k as bt,l as ft,M as xt,F as at,R as Ae,C as se,m as it,A as Ct,X as vt,Y as kt,n as Nt,o as wt,q as jt,s as It,t as Pt,v as St,w as Lt,H as qt,x as At,y as _t,z as Bt,E as Zt,G as Qt,J as Mt,K as Ee,L as zt,N as $t,O as Tt}from"./vendor-Cpgv2L5x.js";(function(){const a=document.createElement("link").relList;if(a&&a.supports&&a.supports("modulepreload"))return;for(const r of document.querySelectorAll('link[rel="modulepreload"]'))n(r);new MutationObserver(r=>{for(const c of r)if(c.type==="childList")for(const k of c.addedNodes)k.tagName==="LINK"&&k.rel==="modulepreload"&&n(k)}).observe(document,{childList:!0,subtree:!0});function i(r){const c={};return r.integrity&&(c.integrity=r.integrity),r.referrerPolicy&&(c.referrerPolicy=r.referrerPolicy),r.crossOrigin==="use-credentials"?c.credentials="include":r.crossOrigin==="anonymous"?c.credentials="omit":c.credentials="same-origin",c}function n(r){if(r.ep)return;r.ep=!0;const c=i(r);fetch(r.href,c)}})();const Pe=()=>!window.invokeNative,Ft=()=>{},pe=e=>{var a;return(a=e==null?void 0:e.toFixed(2))==null?void 0:a.replace(/\B(?=(\d{3})+(?!\d))/g,",")},oe=(e,a)=>a==null?void 0:a.replace("{amount}",e==null?void 0:e.toString()),rt=(e,a)=>de(e).format(a),Je=e=>new Promise((a,i)=>{fetch(`locales/${e}.json`).then(n=>n.json()).then(n=>a(n)).catch(n=>i(n))});var Ce=(e=>(e.Open="open",e.Closed="closed",e.Closing="closing",e))(Ce||{}),re=(e=>(e.Open="open",e.Closed="closed",e.Closing="closing",e))(re||{}),Ne=(e=>(e.Oldest="oldest",e.Newest="newest",e.AmountAsc="amountAsc",e.AmountDesc="amountDesc",e))(Ne||{}),v=(e=>(e.All="all",e.Paid="paid",e.Unpaid="unpaid",e.Rejected="rejected",e.Cancelled="cancelled",e.Recurring="recurring",e.NotAccepted="not_accepted",e))(v||{}),K=(e=>(e.Personal="__personal",e.Society="society",e))(K||{}),ge=(e=>(e.Open="open",e.Closed="closed",e.Closing="closing",e))(ge||{}),R=(e=>(e.Personal="personal",e.Business="business",e))(R||{});const Ot={UIVisible:!1,setUIVisible:J((e,a)=>{e.UIVisible=a}),acceptInvoiceVisible:!1,setAcceptInvoiceVisible:J((e,a)=>{e.acceptInvoiceVisible=a}),quickCreateInvoiceVisible:!1,setQuickCreateInvoiceVisible:J((e,a)=>{e.quickCreateInvoiceVisible=a}),totalInvoices:0,setTotalInvoices:J((e,a)=>{e.totalInvoices=a}),invoices:[],setInvoices:J((e,a)=>{e.invoices=a}),companyConfig:null,setCompanyConfig:J((e,a)=>{e.companyConfig=a}),jobInfo:null,setJobInfo:J((e,a)=>{e.jobInfo=a}),playerData:null,setPlayerData:J((e,a)=>{e.playerData=a}),menuType:R.Personal,setMenuType:J((e,a)=>{e.menuType=a}),createInvoiceModalOpen:ge.Closed,setCreateInvoiceModalOpen:J((e,a)=>{e.createInvoiceModalOpen=a}),viewInvoice:null,setViewInvoice:J((e,a)=>{e.viewInvoice=a}),viewInvoiceModalOpen:re.Closed,setViewInvoiceModalOpen:J((e,a)=>{e.viewInvoiceModalOpen=a}),settingsConfig:{language:"en",showFullName:!0,allowOverdraft:!1,overdraftLimit:0,currencyFormat:"{amount}$",currencySymbol:"$",dateFormat:"DD-MM-YYYY",highlightNewInvoiceDuration:10,dateTimeFormat:"DD-MM-YYYY HH:mm",societyFilters:[]},setSettingsConfig:J((e,a)=>{e.settingsConfig=a}),filters:{status:v.All,society:"all",orderBy:Ne.Newest,type:K.Personal,dateRange:{dateFrom:"",dateTo:""}},setFilters:J((e,a)=>{e.filters=a}),appSettings:{appSize:1,confirmCancel:!0,confirmPayment:!0},setAppSettings:J((e,a)=>{e.appSettings=a}),flexOasisData:{status:!1},setFlexOasisData:J((e,a)=>{e.flexOasisData=a}),hasNewInvoice:!1,setHasNewInvoice:J((e,a)=>{e.hasNewInvoice=a}),mugshot:"",setMugshot:J((e,a)=>{e.mugshot=a}),customModal:null,setCustomModal:J((e,a)=>{e.customModal=a}),statisticsOpen:Ce.Closed,setStatisticsOpen:J((e,a)=>{e.statisticsOpen=a}),settingsDrawerOpen:!1,setSettingsDrawerOpen:J((e,a)=>{e.settingsDrawerOpen=a}),resizeBy:1,setResizeBy:J((e,a)=>{e.resizeBy=a})},Wt=dt(pt(Ot,{storage:"sessionStorage"}),{name:"tgg-billing-store"});var W=(e=>(e.Create="create",e.Dashboard="dashboard",e.Details="details",e.Accept="accept",e))(W||{});const nt=gt(),_=nt.useStoreActions,N=nt.useStoreState,Et=G.div.attrs({className:"tgg-invoice-details"})`
	position: relative;

	display: flex;
	flex-direction: column;

	gap: 0.5em;

	height: 100%;
	width: 100%;

	padding: 1.25em 0.75em 1em 0.75em;

	z-index: 2;

	.tgg-highlight-new {
		display: flex;
		justify-content: center;
		align-items: center;
		color: #ffffff;

		width: 50px;
		height: 25px;
		background-color: #00c91b;

		border-radius: 5px;

		position: absolute;

		top: -0.4em;
		left: -0.75em;

		transform: rotate(-35deg);
	}

	.tgg-invoice-header {
		.tgg-invoice-subtitle {
			font-size: 0.85em;
			font-weight: 600;
			text-align: start;
		}
	}

	.tgg-invoice-body-wrapper {
		display: flex;
		flex-direction: column;
		gap: 0.25em;

		.tgg-invoice-row {
			display: flex;
			justify-content: space-between;

			.tgg-invoice-label {
				font-size: 0.8em;
				color: #000;
				font-weight: 600;

				text-align: start;
			}

			.tgg-invoice-value {
				font-size: 0.8em;
				color: #000;

				text-align: end;
			}
		}

		.tgg-notes {
			display: flex;
			flex-direction: column;

			.tgg-invoice-label {
				font-size: 0.8em;
				color: #000;
				font-weight: 600;
				text-align: start;
				height: 1em;
				line-height: 1em;
			}

			.tgg-invoice-value {
				font-size: 0.8em;
				color: #000;
				text-align: start;

				height: 2em;
				line-height: 1em;

				overflow: hidden auto;
			}
		}

		.tgg-divider-dashed {
			height: 1px;
			width: 100%;
			border-top: 2px dashed rgba(97, 97, 97, 0.5);
			margin: 0.35em 0;
		}

		.tgg-invoice-items-container {
			padding: 0.25em 0;

			> div:first-child {
				padding-bottom: 0.25em;
			}

			.tgg-invoice-items-wrapper {
				display: flex;
				flex-direction: column;
				gap: 0.25em;

				width: 100%;
				height: 4.5em;

				overflow-y: auto;
				overflow-x: hidden;

				padding-right: 0.25em;

				&.tgg-longer-view {
					height: 7.5em;
				}

				&.tgg-scrollbar-style {
					&::-webkit-scrollbar {
						width: 3px;
						height: 3px;

						background-clip: padding-box;
						padding: 1em 0;
					}

					&::-webkit-scrollbar-button {
						width: 0px;
						height: 0px;
					}

					&::-webkit-scrollbar-thumb {
						background: var(--color-primary);
						border: 0px none var(--color-primary);
						border-radius: 50px;
						opacity: 0.7;
					}

					&::-webkit-scrollbar-thumb:hover {
						background: var(--color-primary);
						opacity: 0.9;
					}

					&::-webkit-scrollbar-thumb:active {
						background: var(--color-primary);
						opacity: 0.7;
					}

					&::-webkit-scrollbar-track {
						background: transparent;
						border: 0px none transparent;

						border-radius: 50px;
					}

					&::-webkit-scrollbar-track:hover {
						background: transparent;
					}

					&::-webkit-scrollbar-track:active {
						background: transparent;
					}

					&::-webkit-scrollbar-corner {
						background: transparent;
					}
				}

				.tgg-invoice-row {
					display: flex;
					justify-content: space-between;

					.tgg-invoice-label {
						font-size: 0.8em;
						color: #000;
						font-weight: 600;
					}

					.tgg-items-label {
						text-decoration: underline;
					}

					.tgg-invoice-value {
						font-size: 0.8em;
						color: #000;
					}
				}
			}
		}
	}

	${({$invoiceLocation:e})=>(e===W.Details||e===W.Accept)&&`
		.tgg-invoice-subtitle {
			font-size: 1.2em !important;
		}

		.tgg-notes {
			height: 4.5em !important;

			.tgg-invoice-value {
				height: 100% !important;
			} 
		}

		.tgg-invoice-value {
			font-size: 0.9em !important;
		}

		.tgg-invoice-label {
			font-size: 0.95em !important;
		}

		.tgg-invoice-items-container {
			.tgg-items-label {
				font-size: 0.95em !important;
			}

			.tgg-invoice-items-wrapper {
				height: 15em !important;
			}

			.tgg-invoice-label {
				font-size: 0.85em !important;
			}

			.tgg-invoice-value {
				font-size: 0.85em !important;
			}
		}
	`}

	.tgg-scrollbar-style {
		&::-webkit-scrollbar {
			width: 3px;
			height: 3px;

			background-clip: padding-box;
			padding: 1em 0;
		}

		&::-webkit-scrollbar-button {
			width: 0px;
			height: 0px;
		}

		&::-webkit-scrollbar-thumb {
			background: var(--color-primary);
			border: 0px none var(--color-primary);
			border-radius: 50px;
			opacity: 0.7;
		}

		&::-webkit-scrollbar-thumb:hover {
			background: var(--color-primary);
			opacity: 0.9;
		}

		&::-webkit-scrollbar-thumb:active {
			background: var(--color-primary);
			opacity: 0.7;
		}

		&::-webkit-scrollbar-track {
			background: transparent;
			border: 0px none transparent;

			border-radius: 50px;
		}

		&::-webkit-scrollbar-track:hover {
			background: transparent;
		}

		&::-webkit-scrollbar-track:active {
			background: transparent;
		}

		&::-webkit-scrollbar-corner {
			background: transparent;
		}
	}
`,Ye=({invoice:e,invoiceLocation:a})=>{var o;const{t:i}=ne(),[n,r]=g.useState(0),[c,k]=g.useState(0),[C,p]=g.useState(0),j=N(P=>P.settingsConfig),m=j.dateTimeFormat,Z=j.currencySymbol,q=j.currencyFormat;g.useEffect(()=>{y()},[e]);const y=()=>{var I;let P=0,h=0,d=0;(I=e==null?void 0:e.items)==null||I.forEach(u=>{P+=u.price*u.quantity}),h=P*(e.taxPercentage/100),d=P+h,r(P),p(h),k(d)};return t.jsxs(Et,{$invoiceLocation:a,children:[t.jsx("div",{className:"tgg-invoice-header",children:t.jsx("div",{className:"tgg-invoice-subtitle",children:e.senderCompanyName?e.senderCompanyName:i("invoice.personalInovice")})}),t.jsxs("div",{className:"tgg-invoice-body-wrapper",children:[t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.status"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:i(`invoice.${e.status}Status`)})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.date"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:rt(e.timestamp,m)})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.from"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:e.senderCompanyName||e.senderName})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.to"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:e.recipientType==="company"?e.recipientName||e.recipientCompany||i("general.hidden"):j.showFullName?e.recipientName:i("general.hidden")})]}),t.jsxs("div",{className:"tgg-invoice-items-container",children:[t.jsx("div",{className:"tgg-invoice-row",children:t.jsxs("div",{className:"tgg-invoice-label tgg-items-label",children:[i("invoice.items"),":"]})}),t.jsx("div",{className:`tgg-invoice-items-wrapper tgg-scrollbar-style${e.notes?"":" tgg-longer-view"}`,children:(o=e==null?void 0:e.items)==null?void 0:o.map((P,h)=>t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsx("div",{className:"tgg-invoice-label",children:P.label}),t.jsxs("div",{className:"tgg-invoice-value",children:[P.quantity," x ",Z,P.price.toFixed(2)]})]},h))})]}),t.jsx("div",{className:"tgg-invoice-row tgg-notes",children:e.notes&&t.jsxs(t.Fragment,{children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.notes"),":"]}),t.jsx("div",{className:"tgg-invoice-value tgg-scrollbar-style",children:e.notes})]})}),t.jsx("div",{className:"tgg-divider-dashed"}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.subTotal"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:oe(pe(n),q)})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.vat"),"(",e.taxPercentage,"%):"]}),t.jsx("div",{className:"tgg-invoice-value",children:oe(pe(C),q)})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.total"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:oe(pe(c),q)})]})]})]})};var He=(e=>(e[e.ConfirmPayment=0]="ConfirmPayment",e[e.ConfirmCancel=1]="ConfirmCancel",e))(He||{});const Vt=G.div.attrs({className:"tgg-invoice-barcode"})`
	position: relative;

	display: flex;
	justify-content: center;
	align-items: center;

	height: 48px;
	width: 100%;

	${({$status:e})=>(e===v.Paid||e===v.Cancelled||e===v.Rejected)&&`
		.tgg-barcode-wrapper {
			position: absolute;
			top: 10px;
		}
	`}

	${({$invoiceLocation:e})=>(e===W.Details||e===W.Accept)&&`
		height: 78px;

		.tgg-barcode-wrapper {
			top: 10px;
		}
	`}

	.tgg-barcode-wrapper {
		display: flex;
		align-items: center;
		margin-top: 5.5px;

		width: 90%;

		overflow: hidden;

		z-index: 1;

		svg {
			width: 100%;
			height: 100%;
		}

		${({$isPersonal:e})=>e?`
			text::selection {
				background: var(--color-primary-60);
			}`:`
			text::selection {
				background: var(--color-secondary-60);
			}
		`}

		&:hover {
			user-select: all;
			cursor: text;
		}
	}
`,Ht=({uuid:e,status:a,isPersonal:i,invoiceLocation:n})=>{const r=N(j=>j.viewInvoiceModalOpen);g.useEffect(()=>{},[r]);const c=()=>a===v.Paid||a===v.Cancelled||a===v.Rejected?n===W.Details?[15,.75]:[25,1]:[15,.8],[k,C]=c(),p=j=>{const m=j.substring(0,3),Z=j.substring(3,6),q=j.substring(6,9),y=j.substring(9,12),o=j.substring(12);return`${m} ${Z} ${q} ${y} ${o}`};return t.jsx(Vt,{$status:a,$invoiceLocation:n,$isPersonal:i,children:t.jsx("div",{className:"tgg-barcode-wrapper",children:t.jsx(mt,{value:p(e),background:"transparent",format:"CODE128",fontSize:a===v.Paid||a===v.Cancelled||a===v.Rejected?21:16,width:C,height:k})})})};async function Y(e,a,i,n,r=1e4){const c={method:"post",headers:{"Content-Type":"application/json; charset=UTF-8"},body:JSON.stringify(a)};if(Pe()&&n)return n;const k=window.GetParentResourceName?window.GetParentResourceName():"nui-frame-app";try{const C=fetch(`https://${i??k}/${e}`,c),p=new Promise((Z,q)=>setTimeout(()=>q(new Error("Request timed out")),r)),j=await Promise.race([C,p]),m=await j.json();if(!j.ok)throw new Error(`HTTP error: ${j.status} - ${j.statusText}`);return m}catch(C){throw console.error("An error occurred:",C),C}}const Rt=G.div.attrs({className:"tgg-invoice-footer-container"})`
	position: relative;

	.tgg-additional-actions {
		display: flex;

		height: 42px;

		.tgg-button-placeholer {
			width: 50%;
		}

		.tgg-draft-btn,
		.tgg-cancel-btn {
			display: flex;
			justify-content: center;

			margin-top: 10px;

			color: rgba(255, 255, 255, 0.75);

			font-size: 0.75em;
			letter-spacing: 1px;
			text-transform: uppercase;

			width: 50%;

			background-color: transparent;
			outline: none;
			border: none;

			transition: color 0.25s ease-in-out;

			.tgg-label {
				position: relative;
				padding: 0 2.5px;

				white-space: nowrap;
				overflow: hidden;
				text-overflow: ellipsis;
				width: fit-content;

				&:after {
					content: '';
					position: absolute;
					bottom: -2px;
					left: 50%;
					right: 50%;
					transform: translateX(-50%);
					width: 0;
					height: 2px;
					background-color: ${({$isPersonalInvoice:e})=>e?"var(--color-primary)":"var(--color-secondary)"};
					transition: width 0.2s linear;
				}
			}

			&:hover:not(:disabled) {
				cursor: pointer;
				color: #fff;

				.tgg-label:after {
					width: 100%;
				}
			}

			&:disabled {
				cursor: not-allowed;

				.tgg-label {
					color: rgba(255, 255, 255, 0.5);
				}
			}
		}
	}

	${({$invoiceLocation:e})=>(e===W.Details||e===W.Accept)&&`
		.tgg-additional-actions {
			height: 66px;

			.tgg-cancel-btn,
			.tgg-draft-btn {
				font-size: 1em;
				margin-top: 17.5px;
			}
		}
	`}

	.tgg-status-wrapper {
		position: relative;

		display: flex;
		width: 100%;
		justify-content: center;

		.tgg-paid-stamp,
		.tgg-canceled-stamp {
			display: flex;
			justify-content: center;
			align-items: center;

			position: absolute;
			top: -27.5px;

			width: fit-content;
			height: fit-content;

			transform: rotate(-10deg);

			padding: 5px 20px;

			border: 5px solid #ffffff96;

			z-index: 1;

			filter: opacity(0.65);

			user-select: none;
			--webkit-user-drag: none;

			&.tgg-canceled-stamp {
				top: -30px;
				transform: rotate(-8.5deg);

				padding: 7.5px 15px;
			}

			.tgg-label {
				color: #ffffff96;
				font-size: 1em;
				font-weight: 800;
				letter-spacing: 1px;
				text-transform: uppercase;

				pointer-events: none;
			}
		}

		${({$invoiceLocation:e})=>e===W.Details&&`
				.tgg-paid-stamp,
				.tgg-canceled-stamp {
					padding: 7.5px 25px;

					.tgg-label {
						font-size: 1.5em;
					}
				}
		`}
	}
`,Ue=({invoice:e,invoiceLocation:a})=>{const{t:i}=ne(),[n,r]=g.useState(!1),c=N(s=>s.settingsConfig),k=N(s=>s.companyConfig),C=N(s=>s.appSettings),p=N(s=>s.playerData),j=N(s=>s.invoices),m=N(s=>s.jobInfo),Z=N(s=>s.acceptInvoiceVisible),q=N(s=>s.viewInvoiceModalOpen),y=p==null?void 0:p.identifier,o=m==null?void 0:m.name,P=_(s=>s.setViewInvoice),h=_(s=>s.setCustomModal),d=_(s=>s.setPlayerData),I=_(s=>s.setInvoices),u=_(s=>s.setAcceptInvoiceVisible),M=_(s=>s.setViewInvoiceModalOpen),f=_(s=>s.setFlexOasisData),z=C.confirmPayment,$=C.confirmCancel,ce=()=>{h(null),E()},x=()=>{h(null),V()},A=()=>{z?h({visible:!0,type:He.ConfirmPayment,onOk:ce,onCancel:()=>h(null),bodyText:i("invoice.confirmPayment")}):E()},E=()=>{var s,S;if(c.allowOverdraft&&((s=p==null?void 0:p.money)!=null&&s.bank)){const O=p.money.bank,ee=e.total,Se=c.overdraftLimit;if(O-ee<-Se){f({status:!0,message:"exceedingOverdraftLimit"});return}}else if((S=p==null?void 0:p.money)!=null&&S.bank&&p.money.bank<e.total){f({status:!0,message:"insufficientFunds"});return}r(!0),Y("billing:invoice:pay",e.id,void 0,{success:!0,amountPaid:1e3}).then(O=>{var ee;if(O!=null&&O.success){const Se=j.find(_e=>_e.id===e.id);Se&&(Se.status=v.Paid,I([...j])),r(!1),f({status:!0,message:"invoicePaid"}),O!=null&&O.amountPaid&&p&&d({...p,money:{...p.money,bank:((ee=p.money)==null?void 0:ee.bank)-O.amountPaid}}),q==re.Open&&(P(null),M(re.Closing))}else f({status:!0,message:"invoicePaymentFailed"})})},D=()=>{P(e),M(re.Open)},ie=()=>{$?h({visible:!0,type:He.ConfirmCancel,onOk:x,onCancel:()=>h(null),bodyText:i("invoice.confirmCancel")}):V()},V=()=>{r(!0),Y("billing:invoice:cancel",e.id,void 0,!0).then(s=>{if(s){const S=j.find(O=>O.id===e.id);if(!S)return;S.status=v.Cancelled,I([...j]),r(!1),f({status:!0,message:"invoiceCancelled"})}else f({status:!0,message:"invoiceCancelFailed"});q&&M(re.Closing)})},H=()=>(e.recipientType||(e.recipientCompany?"company":"player"))==="company"?e.recipientCompany===o:e.recipientId===y,X=()=>{var O;if(H())return!1;const s=k==null?void 0:k.cancel,S=(O=m==null?void 0:m.grade)==null?void 0:O.level;return!!(e.sender=="__personal"&&e.senderId===y||e.sender!=="__personal"&&e.sender===o&&s&&s.length>0&&(s!=null&&s.includes("-1")||S!==void 0&&(s!=null&&s.includes(S.toString()))||S!==void 0&&(s!=null&&s.includes(S))))},T=()=>!e||!o?!1:e.sender!=="__personal"&&e.sender!==void 0&&e.sender===o,ve=()=>{var ee;if((e.recipientType||(e.recipientCompany?"company":"player"))!=="company"||!e.recipientCompany||e.recipientCompany!==o)return!1;const S=k==null?void 0:k.acceptCompanyInvoice,O=(ee=m==null?void 0:m.grade)==null?void 0:ee.level;return!S||S.length===0?!1:S.includes("-1")||O&&S.includes(O)},ue=()=>{var ee;if((e.recipientType||(e.recipientCompany?"company":"player"))!=="company"||!e.recipientCompany||e.recipientCompany!==o)return!1;const S=k==null?void 0:k.rejectCompanyInvoice,O=(ee=m==null?void 0:m.grade)==null?void 0:ee.level;return!S||S.length===0?!1:S.includes("-1")||O&&S.includes(O.toString())},je=()=>{var ee;if((e.recipientType||(e.recipientCompany?"company":"player"))!=="company"||!e.recipientCompany||e.recipientCompany!==o)return!1;const S=k==null?void 0:k.canPayCompanyInvoice,O=(ee=m==null?void 0:m.grade)==null?void 0:ee.level;return!S||S.length===0?!1:S.includes("-1")||O&&S.includes(O.toString())},he=()=>{M(re.Closing),P(null)},b=()=>{Y("billing:invoice:accept",e.id,void 0,!0).then(s=>{if(s)if(Z)u(!1),Y("billing:invoice:accepted");else{const S=j.find(O=>O.id===e.id);if(!S)return;S.status=v.Unpaid,I([...j]),r(!1),f({status:!0,message:"invoiceAccepted"})}else f({status:!0,message:"invoiceAcceptFailed"})})},F=()=>{Y("billing:invoice:reject",e.id,void 0,!0).then(s=>{if(s)if(Z)u(!1),Y("billing:invoice:rejected");else{const S=j.find(O=>O.id===e.id);if(!S)return;S.status=v.Rejected,I([...j]),r(!1),f({status:!0,message:"invoiceRejected"})}else f({status:!0,message:"invoiceRejectFailed"});q&&M(re.Closing)})},le=(e==null?void 0:e.sender)==="__personal";return t.jsxs(Rt,{$invoiceLocation:a,$isPersonalInvoice:le,children:[t.jsx(Ht,{isPersonal:e.sender==="__personal",uuid:e.uuid,status:e.status,invoiceLocation:a}),t.jsxs("div",{className:"tgg-status-wrapper",children:[e.status==v.Paid&&t.jsx("div",{className:"tgg-paid-stamp",children:t.jsx("div",{className:"tgg-label",children:i("invoice.paidStamp")})}),e.status==v.Cancelled&&t.jsx("div",{className:"tgg-canceled-stamp",children:t.jsx("div",{className:"tgg-label",children:i("invoice.cancelledStamp")})}),e.status==v.Rejected&&t.jsx("div",{className:"tgg-canceled-stamp",children:t.jsx("div",{className:"tgg-label",children:i("invoice.rejectedStamp")})})]}),t.jsxs("div",{className:"tgg-additional-actions",children:[a===W.Dashboard&&t.jsxs(t.Fragment,{children:[e.status===v.Unpaid&&(e.recipientId===y||e.recipientType==="company"&&e.recipientCompany&&e.recipientCompany===o)&&t.jsxs(t.Fragment,{children:[e.recipientType==="company"?je()?t.jsx("button",{className:"tgg-cancel-btn",onClick:A,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.pay")})}):t.jsx("div",{className:"tgg-button-placeholer"}):t.jsx("button",{className:"tgg-cancel-btn",onClick:A,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.pay")})}),t.jsx("button",{className:"tgg-draft-btn",onClick:D,children:t.jsx("div",{className:"tgg-label",children:i("general.view")})})]}),e.status===v.NotAccepted&&(e.recipientId===y||e.recipientType==="company"&&e.recipientCompany&&e.recipientCompany===o)&&t.jsxs(t.Fragment,{children:[e.recipientType==="company"?ve()?t.jsx("button",{className:"tgg-cancel-btn",onClick:b,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.accept")})}):t.jsx("div",{className:"tgg-button-placeholer"}):t.jsx("button",{className:"tgg-cancel-btn",onClick:b,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.accept")})}),e.recipientType==="company"?ue()?t.jsx("button",{className:"tgg-draft-btn",onClick:F,children:t.jsx("div",{className:"tgg-label",children:i("general.reject")})}):t.jsx("div",{className:"tgg-button-placeholer"}):t.jsx("button",{className:"tgg-draft-btn",onClick:F,children:t.jsx("div",{className:"tgg-label",children:i("general.reject")})})]}),(e.status===v.Unpaid||e.status===v.NotAccepted)&&!H()&&(e.senderId===y||e.sender!=="__personal"&&e.sender===o)&&t.jsxs(t.Fragment,{children:[X()?t.jsx("button",{className:"tgg-cancel-btn",onClick:ie,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.cancel")})}):t.jsx("div",{className:"tgg-button-placeholer"}),t.jsx("button",{className:"tgg-draft-btn",disabled:n,onClick:D,children:t.jsx("div",{className:"tgg-label",children:i("general.view")})})]})]}),a===W.Accept&&t.jsx(t.Fragment,{children:e.status===v.NotAccepted&&(e.recipientId===y||e.recipientType==="company"&&e.recipientCompany&&e.recipientCompany===o)&&t.jsxs(t.Fragment,{children:[e.recipientType==="company"?ve()?t.jsx("button",{className:"tgg-cancel-btn",onClick:b,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.accept")})}):t.jsx("div",{className:"tgg-button-placeholer"}):t.jsx("button",{className:"tgg-cancel-btn",onClick:b,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.accept")})}),e.recipientType==="company"?ue()?t.jsx("button",{className:"tgg-draft-btn",onClick:F,children:t.jsx("div",{className:"tgg-label",children:i("general.reject")})}):t.jsx("div",{className:"tgg-button-placeholer"}):t.jsx("button",{className:"tgg-draft-btn",onClick:F,children:t.jsx("div",{className:"tgg-label",children:i("general.reject")})})]})}),a===W.Details&&t.jsxs(t.Fragment,{children:[e.status===v.Unpaid&&H()&&t.jsxs(t.Fragment,{children:[e.recipientType==="company"?je()?t.jsx("button",{className:"tgg-cancel-btn",onClick:A,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.pay")})}):t.jsx("div",{className:"tgg-button-placeholer"}):t.jsx("button",{className:"tgg-cancel-btn",onClick:A,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.pay")})}),t.jsx("button",{className:"tgg-draft-btn",onClick:he,children:t.jsx("div",{className:"tgg-label",children:i("general.close")})})]}),e.status===v.NotAccepted&&H()&&t.jsxs(t.Fragment,{children:[e.recipientType==="company"?ve()?t.jsx("button",{className:"tgg-cancel-btn",onClick:b,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.accept")})}):t.jsx("div",{className:"tgg-button-placeholer"}):t.jsx("button",{className:"tgg-cancel-btn",onClick:b,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.accept")})}),e.recipientType==="company"?ue()?t.jsx("button",{className:"tgg-draft-btn",onClick:F,children:t.jsx("div",{className:"tgg-label",children:i("general.reject")})}):t.jsx("div",{className:"tgg-button-placeholer"}):t.jsx("button",{className:"tgg-draft-btn",onClick:F,children:t.jsx("div",{className:"tgg-label",children:i("general.reject")})})]}),e.status===v.Unpaid&&!H()&&(e.senderId===y||e.sender!=="__personal"&&e.sender===o)&&t.jsxs(t.Fragment,{children:[X()?t.jsx("button",{className:"tgg-cancel-btn",onClick:ie,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.cancel")})}):t.jsx("div",{className:"tgg-button-placeholer"}),t.jsx("button",{className:"tgg-draft-btn",onClick:he,children:t.jsx("div",{className:"tgg-label",children:i("general.close")})})]}),e.status===v.NotAccepted&&!H()&&(e.senderId===y||T()&&X())&&t.jsxs(t.Fragment,{children:[X()?t.jsx("button",{className:"tgg-cancel-btn",onClick:ie,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.cancel")})}):t.jsx("div",{className:"tgg-button-placeholer"}),t.jsx("button",{className:"tgg-draft-btn",onClick:he,children:t.jsx("div",{className:"tgg-label",children:i("general.close")})})]}),e.status===v.Unpaid&&e.senderId!==y&&e.recipientId!==y&&!(e.recipientType==="company"&&e.recipientCompany===o)&&!T()&&t.jsxs(t.Fragment,{children:[X()?t.jsx("button",{className:"tgg-cancel-btn",onClick:ie,disabled:n,children:t.jsx("div",{className:"tgg-label",children:i("general.cancel")})}):t.jsx("div",{className:"tgg-button-placeholer"}),t.jsx("button",{className:"tgg-draft-btn",onClick:he,children:t.jsx("div",{className:"tgg-label",children:i("general.close")})})]}),(e.status===v.Unpaid||e.status===v.NotAccepted)&&!H()&&!(e.senderId===y||e.sender!=="__personal"&&e.sender===o)&&e.senderId!==y&&e.recipientId!==y&&!(e.recipientType==="company"&&e.recipientCompany===o)&&!T()&&t.jsxs(t.Fragment,{children:[t.jsx("div",{className:"tgg-button-placeholer"}),t.jsx("button",{className:"tgg-draft-btn",onClick:he,children:t.jsx("div",{className:"tgg-label",children:i("general.close")})})]})]})]})]})},Yt=({bodyColor:e="#fff",footerTopColor:a="#fff",footerLeftColor:i="#fff",footerRightColor:n="#fff"})=>t.jsxs("svg",{className:"tgg-invoice-sheet",width:"200",height:"441",viewBox:"0 0 200 441",fill:"none",xmlns:"http://www.w3.org/2000/svg",children:[t.jsx("path",{d:"M3.01886 0H0V345.229L11.1915 351.067C12.0569 351.518 12.4644 352.393 12.4139 353.243L23.4003 353.258C23.4001 353.261 23.4 353.265 23.3999 353.268C23.5126 349.995 26.1711 347.376 29.434 347.376C32.6993 347.376 35.3592 349.999 35.4682 353.275L46.7954 353.291C46.8963 350.007 49.5595 347.376 52.8302 347.376C56.1063 347.376 58.7729 350.016 58.8654 353.307L70.1908 353.323C70.2752 350.024 72.9451 347.376 76.2264 347.376C79.5132 347.376 82.1866 350.033 82.2625 353.34L93.5862 353.355C93.654 350.042 96.3307 347.376 99.6226 347.376C102.92 347.376 105.6 350.051 105.659 353.372L116.982 353.388C117.033 350.059 119.716 347.376 123.019 347.376C126.327 347.376 129.014 350.068 129.056 353.404L140.417 353.42C140.391 353.19 140.377 352.957 140.377 352.721C140.377 349.347 143.081 346.613 146.415 346.613C149.75 346.613 152.453 349.347 152.453 352.721C152.453 352.963 152.439 353.202 152.412 353.437L163.774 353.452C163.79 350.093 166.487 347.376 169.811 347.376C173.141 347.376 175.841 350.103 175.849 353.469L186.858 353.484C186.708 352.563 187.106 351.561 188.054 351.067L200 344.836V0H196.226C196.226 4.63815 192.51 8.39811 187.925 8.39811C183.34 8.39811 179.623 4.63815 179.623 0H166.792C166.792 4.63815 163.076 8.39811 158.491 8.39811C153.906 8.39811 150.189 4.63815 150.189 0H137.358C137.358 4.63815 133.642 8.39811 129.057 8.39811C124.472 8.39811 120.755 4.63815 120.755 0H107.925C107.925 4.63815 104.208 8.39811 99.6226 8.39811C95.0376 8.39811 91.3208 4.63815 91.3208 0H78.4906C78.4906 4.63815 74.7737 8.39811 70.1887 8.39811C65.6037 8.39811 61.8868 4.63815 61.8868 0H49.0566C49.0566 4.63815 45.3397 8.39811 40.7547 8.39811C36.1697 8.39811 32.4528 4.63815 32.4528 0H19.6227C19.6227 4.63815 15.9058 8.39811 11.3208 8.39811C6.73575 8.39811 3.01886 4.63815 3.01886 0ZM58.8659 353.324C58.8667 353.354 58.8672 353.385 58.8676 353.416C58.8678 353.439 58.8679 353.461 58.8679 353.484C58.8679 353.431 58.8672 353.377 58.8659 353.324Z",fill:e}),t.jsx("path",{d:"M99.6226 401H0V360.957L11.1915 355.119C11.9615 354.717 12.369 353.98 12.4139 353.224L23.4003 353.239C23.3976 353.314 23.3962 353.389 23.3962 353.465C23.3962 356.838 26.0994 359.573 29.434 359.573C32.7685 359.573 35.4717 356.838 35.4717 353.465C35.4717 353.395 35.4705 353.325 35.4682 353.256L46.7954 353.271C46.7934 353.336 46.7925 353.4 46.7925 353.465C46.7925 356.838 49.4956 359.573 52.8302 359.573C56.1647 359.573 58.8679 356.838 58.8679 353.465C58.8679 353.406 58.8671 353.347 58.8654 353.288L70.1908 353.304C70.1894 353.357 70.1887 353.411 70.1887 353.465C70.1887 356.838 72.8919 359.573 76.2264 359.573C79.561 359.573 82.2641 356.838 82.2641 353.465C82.2641 353.417 82.2636 353.369 82.2625 353.32L93.5862 353.336C93.5854 353.379 93.5849 353.422 93.5849 353.465C93.5849 356.838 96.2881 359.573 99.6226 359.573C102.957 359.573 105.66 356.838 105.66 353.465C105.66 353.428 105.66 353.39 105.659 353.353L116.982 353.368C116.981 353.401 116.981 353.433 116.981 353.465C116.981 356.838 119.684 359.573 123.019 359.573C126.353 359.573 129.057 356.838 129.057 353.465C129.057 353.438 129.056 353.412 129.056 353.385L140.417 353.401C140.759 356.445 143.314 358.809 146.415 358.809C149.51 358.809 152.061 356.453 152.412 353.417L163.774 353.433L163.774 353.465C163.774 356.838 166.477 359.573 169.811 359.573C173.146 359.573 175.849 356.838 175.849 353.465L175.849 353.45L186.858 353.465C186.967 354.134 187.366 354.76 188.054 355.119L200 361.35V401H99.6226Z",fill:a}),t.jsx("path",{d:"M196.123 441C196.123 436.327 192.425 432.539 187.862 432.539C183.3 432.539 179.602 436.327 179.602 441H166.835C166.835 436.327 163.137 432.539 158.575 432.539C154.013 432.539 150.314 436.327 150.314 441H137.548C137.548 436.327 133.85 432.539 129.287 432.539C124.725 432.539 121.027 436.327 121.027 441H108.261C108.261 436.327 104.562 432.539 100 432.539L100 401H200L200 441H196.123Z",fill:i}),t.jsx("path",{d:"M3.87705 441C3.87705 436.327 7.57543 432.539 12.1376 432.539C16.6998 432.539 20.3982 436.327 20.3982 441H33.1645C33.1645 436.327 36.8629 432.539 41.4251 432.539C45.9873 432.539 49.6856 436.327 49.6856 441H62.452C62.452 436.327 66.1504 432.539 70.7125 432.539C75.2747 432.539 78.9731 436.327 78.9731 441H91.7394C91.7394 436.327 95.4378 432.539 100 432.539L99.9997 401H-1.51828e-05L0.00021256 441H3.87705Z",fill:n})]}),Xe=({className:e,color:a="#CFCFCF"})=>t.jsx("svg",{className:`tgg-create-invoice-addon ${e??""}`,width:"407",height:"510",viewBox:"0 0 407 510",fill:"none",xmlns:"http://www.w3.org/2000/svg",children:t.jsx("path",{d:"M400.591 65.8435L406.051 67.104L289.586 509.266L0.147241 442.742L116.677 0.296833L121.045 1.30525C119.502 7.99008 123.629 14.6508 130.263 16.1823C136.896 17.7139 143.525 13.5363 145.069 6.8515L163.632 11.1372C162.089 17.8221 166.216 24.4828 172.85 26.0143C179.483 27.5459 186.112 23.3683 187.656 16.6835L206.219 20.9692C204.676 27.6541 208.803 34.3148 215.437 35.8463C222.071 37.3779 228.699 33.2003 230.243 26.5155L248.806 30.8012C247.263 37.4861 251.39 44.1468 258.024 45.6783C264.658 47.2099 271.286 43.0323 272.83 36.3475L291.393 40.6332C289.85 47.3181 293.977 53.9788 300.611 55.5103C307.245 57.0419 313.874 52.8643 315.417 46.1795L333.98 50.4652C332.437 57.15 336.564 63.8107 343.198 65.3423C349.832 66.8739 356.461 62.6963 358.004 56.0115L376.567 60.2972C375.024 66.982 379.151 73.6427 385.785 75.1743C392.419 76.7058 399.048 72.5283 400.591 65.8435Z",fill:a})}),Ut=()=>{const[e,a]=g.useState(()=>typeof window>"u"?"#673ab7":getComputedStyle(document.documentElement).getPropertyValue("--color-secondary").trim()||"#673ab7");return g.useEffect(()=>{const i=()=>{if(typeof window<"u"){const r=getComputedStyle(document.documentElement).getPropertyValue("--color-secondary").trim()||"#673ab7";a(r)}};i();const n=new MutationObserver(i);return document.documentElement&&n.observe(document.documentElement,{attributes:!0,attributeFilter:["style"]}),()=>n.disconnect()},[]),t.jsx("svg",{className:"tgg-invoice-purple",width:"254",height:"377",viewBox:"0 0 254 377",fill:"none",xmlns:"http://www.w3.org/2000/svg",children:t.jsx("path",{opacity:"0.4",fillRule:"evenodd",clipRule:"evenodd",d:"M0.926592 46.475L3.21109 45.7765C4.27188 49.2462 7.94453 51.199 11.4142 50.1382C14.8839 49.0774 16.8367 45.4048 15.7759 41.9351L25.485 38.9667C26.5458 42.4364 30.2185 44.3892 33.6881 43.3284C37.1578 42.2676 39.1106 38.5949 38.0498 35.1253L47.759 32.1569C48.8197 35.6266 52.4924 37.5794 55.9621 36.5186C59.4317 35.4578 61.3845 31.7851 60.3237 28.3155L70.0329 25.3471C71.0937 28.8167 74.7663 30.7695 78.236 29.7087C81.7057 28.648 83.6585 24.9753 82.5977 21.5056L92.3068 18.5373C93.3676 22.0069 97.0403 23.9597 100.51 22.8989C103.98 21.8381 105.932 18.1655 104.872 14.6958L114.581 11.7274C115.642 15.1971 119.314 17.1499 122.784 16.0891C126.254 15.0283 128.206 11.3557 127.146 7.88599L136.855 4.9176C137.915 8.38727 141.588 10.3401 145.058 9.27927C148.527 8.21849 150.48 4.54583 149.419 1.07616L152.275 0.203109L231.142 258.165L223.527 265.59C222.484 266.607 223.025 268.376 224.458 268.636L234.923 270.533L253.026 329.743L250.17 330.616C249.109 327.146 245.436 325.194 241.967 326.254C238.497 327.315 236.544 330.988 237.605 334.457L227.896 337.426C226.835 333.956 223.163 332.003 219.693 333.064C216.223 334.125 214.27 337.798 215.331 341.267L205.622 344.236C204.561 340.766 200.889 338.813 197.419 339.874C193.949 340.935 191.996 344.607 193.057 348.077L183.348 351.046C182.287 347.576 178.615 345.623 175.145 346.684C171.675 347.745 169.723 351.417 170.783 354.887L161.074 357.855C160.013 354.386 156.341 352.433 152.871 353.494C149.401 354.554 147.449 358.227 148.509 361.697L138.8 364.665C137.739 361.195 134.067 359.243 130.597 360.303C127.127 361.364 125.175 365.037 126.235 368.507L116.526 371.475C115.466 368.005 111.793 366.053 108.323 367.113C104.854 368.174 102.901 371.847 103.962 375.316L101.677 376.015L83.4848 316.511L90.6188 309.555C91.6612 308.538 91.1203 306.769 89.6876 306.509L79.8834 304.731L0.926592 46.475ZM211.672 276.188C209.148 276.96 206.477 275.539 205.706 273.016C204.934 270.493 206.355 267.821 208.878 267.05C211.401 266.279 214.072 267.699 214.844 270.222C215.615 272.746 214.195 275.417 211.672 276.188ZM187.826 277.858C188.598 280.381 191.269 281.801 193.792 281.03C196.316 280.258 197.736 277.587 196.964 275.064C196.193 272.541 193.522 271.12 190.998 271.892C188.475 272.663 187.055 275.334 187.826 277.858ZM176.262 287.014C173.739 287.785 171.067 286.365 170.296 283.842C169.525 281.318 170.945 278.647 173.468 277.876C175.992 277.104 178.663 278.525 179.434 281.048C180.206 283.571 178.785 286.242 176.262 287.014ZM152.591 289.255C153.363 291.778 156.034 293.198 158.557 292.427C161.08 291.655 162.501 288.984 161.729 286.461C160.958 283.938 158.287 282.517 155.763 283.289C153.24 284.06 151.82 286.731 152.591 289.255ZM140.852 297.84C138.329 298.611 135.658 297.191 134.886 294.668C134.115 292.144 135.535 289.473 138.058 288.702C140.582 287.93 143.253 289.35 144.024 291.874C144.796 294.397 143.375 297.068 140.852 297.84ZM117.181 300.081C117.953 302.604 120.624 304.024 123.147 303.253C125.671 302.481 127.091 299.81 126.319 297.287C125.548 294.763 122.877 293.343 120.353 294.115C117.83 294.886 116.41 297.557 117.181 300.081ZM105.442 308.666C102.919 309.437 100.248 308.017 99.4763 305.494C98.7048 302.97 100.125 300.299 102.648 299.528C105.172 298.756 107.843 300.176 108.614 302.7C109.386 305.223 107.966 307.894 105.442 308.666Z",fill:e})})},Gt=()=>{const[e,a]=g.useState(()=>typeof window>"u"?"#1e88e5":getComputedStyle(document.documentElement).getPropertyValue("--color-primary").trim()||"#1e88e5");return g.useEffect(()=>{const i=()=>{if(typeof window<"u"){const r=getComputedStyle(document.documentElement).getPropertyValue("--color-primary").trim()||"#1e88e5";a(r)}};i();const n=new MutationObserver(i);return document.documentElement&&n.observe(document.documentElement,{attributes:!0,attributeFilter:["style"]}),()=>n.disconnect()},[]),t.jsx("svg",{className:"tgg-invoice-blue",width:"253",height:"377",viewBox:"0 0 253 377",fill:"none",xmlns:"http://www.w3.org/2000/svg",children:t.jsx("path",{opacity:"0.4",fillRule:"evenodd",clipRule:"evenodd",d:"M0.00277944 46.475L2.28728 45.7765C3.34807 49.2462 7.02072 51.199 10.4904 50.1382C13.9601 49.0774 15.9128 45.4048 14.8521 41.9351L24.5612 38.9667C25.622 42.4364 29.2947 44.3892 32.7643 43.3284C36.234 42.2676 38.1868 38.5949 37.126 35.1253L46.8351 32.1569C47.8959 35.6266 51.5686 37.5794 55.0383 36.5186C58.5079 35.4578 60.4607 31.7851 59.3999 28.3155L69.1091 25.3471C70.1699 28.8167 73.8425 30.7695 77.3122 29.7087C80.7819 28.648 82.7346 24.9753 81.6739 21.5056L91.383 18.5373C92.4438 22.0069 96.1164 23.9597 99.5861 22.8989C103.056 21.8381 105.009 18.1655 103.948 14.6958L113.657 11.7274C114.718 15.1971 118.39 17.1499 121.86 16.0891C125.33 15.0283 127.283 11.3557 126.222 7.88599L135.931 4.9176C136.992 8.38727 140.664 10.3401 144.134 9.27927C147.604 8.21849 149.556 4.54583 148.496 1.07616L151.351 0.203109L230.218 258.165L222.603 265.59C221.561 266.607 222.102 268.376 223.534 268.636L234 270.533L252.102 329.743L249.246 330.616C248.185 327.146 244.513 325.194 241.043 326.254C237.573 327.315 235.621 330.988 236.681 334.457L226.972 337.426C225.911 333.956 222.239 332.003 218.769 333.064C215.299 334.125 213.347 337.798 214.407 341.267L204.698 344.236C203.637 340.766 199.965 338.813 196.495 339.874C193.025 340.935 191.073 344.607 192.133 348.077L182.424 351.046C181.364 347.576 177.691 345.623 174.221 346.684C170.752 347.745 168.799 351.417 169.86 354.887L160.15 357.855C159.09 354.386 155.417 352.433 151.947 353.494C148.478 354.554 146.525 358.227 147.586 361.697L137.876 364.665C136.816 361.195 133.143 359.243 129.673 360.303C126.204 361.364 124.251 365.037 125.312 368.507L115.603 371.475C114.542 368.005 110.869 366.053 107.399 367.113C103.93 368.174 101.977 371.847 103.038 375.316L100.753 376.015L82.561 316.511L89.695 309.555C90.7374 308.538 90.1965 306.769 88.7638 306.509L78.9596 304.731L0.00277944 46.475ZM210.748 276.188C208.225 276.96 205.554 275.539 204.782 273.016C204.011 270.493 205.431 267.821 207.954 267.05C210.478 266.279 213.149 267.699 213.92 270.222C214.692 272.746 213.271 275.417 210.748 276.188ZM186.902 277.858C187.674 280.381 190.345 281.801 192.868 281.03C195.392 280.258 196.812 277.587 196.041 275.064C195.269 272.541 192.598 271.12 190.075 271.892C187.551 272.663 186.131 275.334 186.902 277.858ZM175.338 287.014C172.815 287.785 170.144 286.365 169.372 283.842C168.601 281.318 170.021 278.647 172.544 277.876C175.068 277.104 177.739 278.525 178.51 281.048C179.282 283.571 177.861 286.242 175.338 287.014ZM151.667 289.255C152.439 291.778 155.11 293.198 157.633 292.427C160.157 291.655 161.577 288.984 160.805 286.461C160.034 283.938 157.363 282.517 154.839 283.289C152.316 284.06 150.896 286.731 151.667 289.255ZM139.928 297.84C137.405 298.611 134.734 297.191 133.962 294.668C133.191 292.144 134.611 289.473 137.134 288.702C139.658 287.93 142.329 289.35 143.1 291.874C143.872 294.397 142.452 297.068 139.928 297.84ZM116.257 300.081C117.029 302.604 119.7 304.024 122.223 303.253C124.747 302.481 126.167 299.81 125.395 297.287C124.624 294.763 121.953 293.343 119.43 294.115C116.906 294.886 115.486 297.557 116.257 300.081ZM104.518 308.666C101.995 309.437 99.324 308.017 98.5525 305.494C97.781 302.97 99.2012 300.299 101.725 299.528C104.248 298.756 106.919 300.176 107.691 302.7C108.462 305.223 107.042 307.894 104.518 308.666Z",fill:e})})},Le=(e,a)=>{if(typeof window>"u")return a;const i=e.startsWith("--")?e:`--${e}`;return getComputedStyle(document.documentElement).getPropertyValue(i).trim()||a},me=(e,a)=>{e=e.replace("#","");const i=parseInt(e,16),n=Math.max(0,Math.floor((i>>16)*(1-a))),r=Math.max(0,Math.floor((i>>8&255)*(1-a))),c=Math.max(0,Math.floor((i&255)*(1-a)));return`#${(n<<16|r<<8|c).toString(16).padStart(6,"0")}`},Jt=G.div.attrs({className:"tgg-invoice"})`
	position: relative;

	display: flex;
	justify-content: end;
	align-items: start;

	width: 250px;
	height: 440px;

	z-index: 3;

	/* If the invoice is on the dashboard and it is paid or cancelled */
	${({$status:e,$type:a})=>a===W.Dashboard&&(e===v.Paid||e===v.Cancelled||e===v.Rejected)&&"filter: opacity(0.5);"}

	.tgg-sheet-wrapper {
		position: relative;

		width: 200px;
		height: 440px;

		z-index: 2;

		-webkit-font-smoothing: antialiased;
		backface-visibility: hidden;

		.tgg-invoice-sheet {
			z-index: 2;
		}

		.tgg-invoice-details-wrapper {
			position: absolute;

			top: 0;
			height: 100%;
			width: 100%;
		}
	}

	.tgg-invoice-addon {
		position: absolute;

		left: -17.5px;

		top: 5px;

		width: 200px;
		height: 265px;

		z-index: 1;

		overflow: hidden;

		.tgg-invoice-blue,
		.tgg-invoice-purple {
		}

		.tgg-invoice-new {
			position: absolute;

			top: 45px;
			left: 10px;

			display: flex;
			justify-content: center;
			align-items: center;

			color: #0f1327;

			font-size: 23px;
			font-weight: 600;

			opacity: 0.8;

			border-radius: 5px;

			transform: rotate(340deg);
		}
	}

	.tgg-create-invoice-addon {
		position: absolute;

		right: -57.5px;

		top: 5px;

		width: 407px;
		height: 510px;

		z-index: 1;

		&.tgg-2nd {
			top: 35px;

			transform: rotate(10deg);

			right: -82.5px;

			z-index: 0;
		}
	}

	.tgg-invoice-body {
		position: relative;

		height: 353px;

		/* background-color: #ff000055; */

		z-index: 3;
	}

	.tgg-invoice-footer {
		position: relative;

		height: 88px;
		width: 100%;

		z-index: 3;

		/* background-color: #22ff0054; */
	}

	/* If the invoice is displayed in the View Invoice Details modal */
	${({$type:e})=>(e===W.Details||e===W.Create||e===W.Accept)&&`
			width: 330px;
			height: 725px;

			.tgg-sheet-wrapper {
				width: inherit;
				height: inherit;

				.tgg-invoice-sheet {
					height: 100%;
					width: 100%;
				}
			}

			.tgg-invoice-body { 
				height: 580.5px;
			}

			.tgg-invoice-footer { 
				height: 145px;
			}
		`}
`,Ze=({type:e,body:a,footer:i,invoice:n})=>{const{t:r}=ne(),[c,k]=g.useState([]),C=N(o=>o.settingsConfig),p=N(o=>o.viewInvoice),j=N(o=>o.menuType),m=N(o=>o.createInvoiceModalOpen),Z=N(o=>o.acceptInvoiceVisible);g.useEffect(()=>{n&&q(n)},[n==null?void 0:n.status,n==null?void 0:n.sender]),g.useEffect(()=>{!n&&p&&(n=p),n&&q(n)},[p]),g.useEffect(()=>{if(e===W.Create){let o=[];const P=Le("color-primary","#6366f1"),h=Le("color-secondary","#f59e0b");j===R.Business?o=[h,me(h,.2),me(h,.4)]:j===R.Personal&&(o=[P,me(P,.2),me(P,.4)]),k(o)}},[m,j]),g.useEffect(()=>{if(e===W.Accept){let o=[];const P=Le("color-primary","#6366f1"),h=Le("color-secondary","#f59e0b");(n==null?void 0:n.sender)==="__personal"?o=[P,me(P,.2),me(P,.4)]:o=[h,me(h,.2),me(h,.4)],k(o)}},[Z]);const q=o=>{let P=[];const h=Le("color-primary","#6366f1"),d=Le("color-secondary","#f59e0b");((o==null?void 0:o.status)===v.Cancelled||(o==null?void 0:o.status)===v.Paid||(o==null?void 0:o.status)===v.Rejected)&&(o==null?void 0:o.sender)==="__personal"?P=[h,h,h]:((o==null?void 0:o.status)===v.Unpaid||(o==null?void 0:o.status)===v.NotAccepted)&&(o==null?void 0:o.sender)==="__personal"?P=[h,me(h,.4),me(h,.2)]:((o==null?void 0:o.status)===v.Cancelled||(o==null?void 0:o.status)===v.Paid||(o==null?void 0:o.status)===v.Rejected)&&(o==null?void 0:o.sender)!=="__personal"?P=[d,d,d]:((o==null?void 0:o.status)===v.Unpaid||(o==null?void 0:o.status)===v.NotAccepted)&&(o==null?void 0:o.sender)!=="__personal"&&(P=[d,me(d,.4),me(d,.2)]),k(P)},y=()=>{if(!n)return!1;const o=C.highlightNewInvoiceDuration,P=new Date().getTime(),h=new Date(n.timestamp).getTime();return(P-h)/6e4<=o};return t.jsxs(Jt,{$status:n==null?void 0:n.status,$type:e,children:[t.jsxs("div",{className:"tgg-sheet-wrapper",children:[t.jsx(Yt,{footerTopColor:c[0],footerRightColor:c[1],footerLeftColor:c[2]}),t.jsxs("div",{className:"tgg-invoice-details-wrapper",children:[t.jsx("div",{className:"tgg-invoice-body",children:a}),t.jsx("div",{className:"tgg-invoice-footer",children:i})]})]}),e===W.Dashboard&&n&&t.jsxs("div",{className:"tgg-invoice-addon",children:[n.sender==="__personal"?t.jsx(Gt,{}):t.jsx(Ut,{}),y()&&t.jsx("div",{className:"tgg-invoice-new",children:r("invoice.new")})]}),e===W.Create&&t.jsxs("div",{className:"tgg-create-invoice-addon",children:[t.jsx(Xe,{}),t.jsx(Xe,{className:"tgg-2nd",color:"#6B6B6B"})]})]})},Xt=G.div.attrs({className:"tgg-accept-invoice"})`
	position: relative;

	width: 100%;
	height: 100%;

	display: flex;
	justify-content: end;
	align-items: center;

	padding: 0 5em;

	overflow: hidden;

	z-index: 999999;

	.tgg-invoice-popup {
		position: absolute;
		bottom: -100%;
		transition: bottom 0.5s ease-in-out;
	}

	.tgg-visible {
		bottom: 40px;
	}
`,Kt=({invoice:e})=>{const a=N(i=>i.acceptInvoiceVisible);return e?t.jsx(Xt,{children:t.jsx("div",{className:`tgg-invoice-popup${a?" tgg-visible":""}`,children:t.jsx(Ze,{invoice:e,body:t.jsx(Ye,{invoice:e,invoiceLocation:W.Accept}),footer:t.jsx(Ue,{invoice:e,invoiceLocation:W.Accept}),type:W.Accept})})}):t.jsx(t.Fragment,{})},Dt=G.div.attrs({className:"tgg-invoice-create-footer"})`
	height: 100%;
	width: 100%;

	.tgg-additional-actions {
		display: flex;

		width: 100%;
		height: 60px;

		.tgg-cancel-btn,
		.tgg-draft-btn {
			position: relative;

			width: 50%;

			outline: none;
			border: none;

			background-color: transparent;

			.tgg-label {
				position: relative;
				color: rgba(255, 255, 255, 0.75);

				font-size: 1.15em;
				letter-spacing: 1px;
				text-transform: uppercase;
				transition: color 0.25s ease-in-out;

				width: fit-content;
				margin: 0 auto;

				&:after {
					content: '';
					position: absolute;
					bottom: -2px;
					left: 50%;
					right: 50%;
					transform: translateX(-50%);
					width: 0;
					height: 2px;
					background-color: ${({$menuType:e})=>e===R.Personal?"var(--color-primary)":"var(--color-secondary)"};
					transition: width 0.2s linear;
				}
			}

			&:hover:not(:disabled) {
				cursor: pointer;

				.tgg-label {
					color: #fff;

					&:after {
						width: 100%;
					}
				}
			}

			&:disabled {
				cursor: not-allowed;

				.tgg-label {
					color: rgba(255, 255, 255, 0.5);
				}
			}
		}
	}

	.tgg-invoice-create-btn {
		height: 79px;
		width: 100%;

		background-color: transparent;
		outline: none;
		border: none;

			.tgg-label {
			position: relative;

			color: rgba(255, 255, 255, 0.85);
			font-size: 1.75em;
			letter-spacing: 1px;
			text-transform: uppercase;
			transition: color 0.25s ease-in-out;

			width: fit-content;

			margin: 0 auto;
			margin-top: 5px;

			&:after {
				content: '';

				position: absolute;
				bottom: -2px;
				left: 50%;
				right: 50%;
				transform: translateX(-50%);

				width: 0;
				height: 2px;
				background-color: ${({$menuType:e})=>e===R.Personal?"var(--color-primary)":"var(--color-secondary)"};

				transition: width 0.2s linear;
			}
		}

		&:hover:not(:disabled) {
			cursor: pointer;

			.tgg-label {
				color: #fff;

				&:after {
					width: 100%;
				}
			}
		}

		&:disabled {
			cursor: not-allowed;

			.tgg-label {
				color: rgba(255, 255, 255, 0.5);
			}
		}
	}
`,st=({invoiceDetails:e,handleCreateInvoice:a,handleCancelInvoice:i})=>{const{t:n}=ne(),[r,c]=g.useState(!1),k=N(y=>y.companyConfig),C=N(y=>y.menuType),p=N(y=>y.jobInfo),j=_(y=>y.setMenuType);g.useEffect(()=>{var I;const y=(e==null?void 0:e.recipientType)==="company",o=y?(e==null?void 0:e.recipientCompany)&&(e==null?void 0:e.recipientName):(e==null?void 0:e.recipientId)&&(e==null?void 0:e.recipientName),P=(e==null?void 0:e.sender)==="__personal"?(e==null?void 0:e.senderId)&&(e==null?void 0:e.senderName):(e==null?void 0:e.sender)&&(e==null?void 0:e.senderName),d=y?(()=>{var f;const u=k==null?void 0:k.createCompanyInvoice,M=(f=p==null?void 0:p.grade)==null?void 0:f.level;return!u||u.length===0?!1:u.includes("-1")||M&&u.includes(M.toString())})():!0;o&&P&&(e!=null&&e.total)&&((I=e==null?void 0:e.items)==null?void 0:I.length)>0&&d?c(!0):c(!1)},[e,k,p]);const m=()=>{const y=k==null?void 0:k.create;return!!(y!=null&&y.includes("__personal"))},Z=()=>{const y=k==null?void 0:k.create,o=p==null?void 0:p.grade.level;return!!(y!=null&&y.includes("-1")||o&&(y!=null&&y.includes(o)))},q=()=>{C===R.Personal?j(R.Business):j(R.Personal)};return t.jsxs(Dt,{$menuType:C,children:[t.jsx("button",{className:"tgg-invoice-create-btn",disabled:!r,onClick:a,children:t.jsx("div",{className:"tgg-label",children:n("general.create")})}),t.jsxs("div",{className:"tgg-additional-actions",children:[t.jsx("button",{className:"tgg-cancel-btn",onClick:i,children:t.jsx("div",{className:"tgg-label",children:n("general.cancel")})}),Z()&&m()&&t.jsx("button",{className:"tgg-draft-btn",onClick:q,children:t.jsx("div",{className:"tgg-label",children:C===R.Business?n("invoice.personal"):n("invoice.society")})})]})]})},ea=[{value:"all",label:"All"},{value:"byMe",label:"Created by me"},{value:"received",label:"Received"},{value:"police",label:"Police Department"},{value:"mechanic",label:"Mechanic Shop"},{value:"ambulance",label:"Ambulance Service"},{value:"taxi",label:"Taxi Service"},{value:"cardealer",label:"Car Dealership"}],ze=[{id:84,items:[{key:"speeding",label:"Speeding",price:100,priceChange:!1,quantity:1,quantityChange:!1},{key:"parking",label:"Parking",price:25,priceChange:!1,quantity:1,quantityChange:!1}],notes:"Police fine for speeding in a no-parking zone.",senderId:"SGP07132",senderName:"John Malik",sender:"__personal",senderCompanyName:"Law Enforcement",recipientId:"BZQ08355",recipientName:"Nick Walker",status:"not_accepted",taxPercentage:10,timestamp:1714405699e3,total:125,uuid:"LSA83000000000"},{id:83,items:[{key:"cop-bait",label:"Cop Bait",price:150,priceChange:!0,quantity:1,quantityChange:!0}],recipientId:"SGP07132",recipientName:"Alis Wright",sender:"police",senderCompanyName:"Law Enforcement",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1714405686e3,total:150,uuid:"LSA83000000000"},{id:82,items:[{key:"oil-change",label:"Oil Change",price:25,priceChange:!1,quantity:1,quantityChange:!1}],notes:"Periodic maintenance.",recipientId:"SGP07132",recipientName:"John Speed",sender:"mechanic",senderCompanyName:"LS Customs",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1714405363e3,total:25,uuid:"LSA10000000000"},{id:81,items:[{key:"speeding",label:"Speeding",price:100,priceChange:!1,quantity:1,quantityChange:!1}],notes:"",recipientId:"SGP07132",recipientName:"Second Debugov",sender:"police",senderCompanyName:"Law Enforcement",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:171440531e4,total:100,uuid:"LSA10000000000"},{id:8123,items:[{key:"speeding",label:"Speeding",price:100,priceChange:!1,quantity:1,quantityChange:!1}],notes:"test",recipientId:"SGP07132",recipientName:"Second Debugov",sender:"police",senderCompanyName:"Law Enforcement",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:171440531e4,total:100,uuid:"LSA10000000000"},{id:8121243,items:[{key:"speeding",label:"Speeding",price:100,priceChange:!1,quantity:1,quantityChange:!1}],notes:"test",recipientId:"SGP07132",recipientName:"Second Debugov",sender:"police",senderCompanyName:"Law Enforcement",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:171440531e4,total:100,uuid:"LSA10000000000"},{id:121243,items:[{key:"speeding",label:"Speeding",price:100,priceChange:!1,quantity:1,quantityChange:!1}],notes:"test",recipientId:"SGP07132",recipientName:"Second Debugov",sender:"police",senderCompanyName:"Law Enforcement",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:171440531e4,total:100,uuid:"LSA10000000000"},{id:12121243,items:[{key:"speeding",label:"Speeding",price:100,priceChange:!1,quantity:1,quantityChange:!1}],notes:"test",recipientId:"SGP07132",recipientName:"Second Debugov",sender:"police",senderCompanyName:"Law Enforcement",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:171440531e4,total:100,uuid:"LSA10000000000"},{id:1217243,items:[{key:"speeding",label:"Speeding",price:100,priceChange:!1,quantity:1,quantityChange:!1}],notes:"test",recipientId:"SGP07132",recipientName:"Second Debugov",sender:"police",senderCompanyName:"Law Enforcement",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:171440531e4,total:100,uuid:"LSA10000000000"}],ta=[{id:1,items:[{key:"coca-cola",label:"Coca-Cola",price:109,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ83887",recipientName:"Customer 1",sender:"__personal",senderId:"BZQ0832525",senderName:"Nick Walker",status:"rejected",taxPercentage:10,timestamp:1712918870124,total:533,uuid:"LSA000000000000001"},{id:2,items:[{key:"coca-cola",label:"Coca-Cola",price:109,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:97,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ83887",recipientName:"Customer 2",sender:"__personal",senderId:"steam:110000100000000",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:de().valueOf(),total:303,uuid:"LSA000000000000002"},{id:3,items:[{key:"coca-cola",label:"Coca-Cola",price:118,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:50,quantity:3,priceChange:!1}],recipientId:"BZQ55187",recipientName:"Customer 3",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"cancelled",taxPercentage:10,timestamp:1712918870124,total:268,uuid:"LSA000000000000003"},{id:4,items:[{key:"coca-cola",label:"Coca-Cola",price:117,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:95,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ40828",recipientName:"Customer 4",sender:"mechanic",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:402,uuid:"LSA000000000000004"},{id:5,items:[{key:"coca-cola",label:"Coca-Cola",price:125,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:71,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ38287",recipientName:"Customer 5",sender:"mechanic",senderCompanyName:"Mechanic Shop",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:321,uuid:"LSA000000000000005"},{id:6,items:[{key:"coca-cola",label:"Coca-Cola",price:133,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:50,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ41331",recipientName:"Customer 6",sender:"mechanic",senderCompanyName:"Mechanic Shop",senderId:"BZQ08355",senderName:"Nick Walker",status:"cancelled",taxPercentage:10,timestamp:1712918870124,total:582,uuid:"LSA000000000000006"},{id:7,items:[{key:"coca-cola",label:"Coca-Cola",price:104,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:88,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ55961",recipientName:"Customer 7",sender:"mechaninc",senderCompanyName:"Mechanic Shop",senderId:"BZQ08355",senderName:"Nick Walker",status:"cancelled",taxPercentage:10,timestamp:1712918870124,total:664,uuid:"LSA000000000000007"},{id:8,items:[{key:"coca-cola",label:"Coca-Cola",price:145,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:92,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ82883",recipientName:"Customer 8",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:421,uuid:"LSA000000000000008"},{id:9,items:[{key:"coca-cola",label:"Coca-Cola",price:128,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:78,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ94256",recipientName:"Customer 9",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:568,uuid:"LSA000000000000009"},{id:10,items:[{key:"coca-cola",label:"Coca-Cola",price:124,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:94,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ48636",recipientName:"Customer 10",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:406,uuid:"LSA000000000000010"},{id:11,items:[{key:"coca-cola",label:"Coca-Cola",price:136,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:60,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ88036",recipientName:"Customer 11",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:196,uuid:"LSA000000000000011"},{id:12,items:[{key:"coca-cola",label:"Coca-Cola",price:146,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:84,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ24960",recipientName:"Customer 12",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:752,uuid:"LSA000000000000012"},{id:13,items:[{key:"coca-cola",label:"Coca-Cola",price:137,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:66,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ56206",recipientName:"Customer 13",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:340,uuid:"LSA000000000000013"},{id:14,items:[{key:"coca-cola",label:"Coca-Cola",price:112,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:57,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ51165",recipientName:"Customer 14",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:338,uuid:"LSA000000000000014"},{id:15,items:[{key:"coca-cola",label:"Coca-Cola",price:136,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:54,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ49116",recipientName:"Customer 15",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:190,uuid:"LSA000000000000015"},{id:16,items:[{key:"coca-cola",label:"Coca-Cola",price:101,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:75,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ79982",recipientName:"Customer 16",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:378,uuid:"LSA000000000000016"},{id:17,items:[{key:"coca-cola",label:"Coca-Cola",price:110,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:59,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ27854",recipientName:"Customer 17",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:566,uuid:"LSA000000000000017"},{id:18,items:[{key:"coca-cola",label:"Coca-Cola",price:102,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:69,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ55439",recipientName:"Customer 18",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:546,uuid:"LSA000000000000018"},{id:19,items:[{key:"coca-cola",label:"Coca-Cola",price:132,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:75,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ35206",recipientName:"Customer 19",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:489,uuid:"LSA000000000000019"},{id:20,items:[{key:"coca-cola",label:"Coca-Cola",price:128,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:58,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ26202",recipientName:"Customer 20",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:628,uuid:"LSA000000000000020"},{id:21,items:[{key:"coca-cola",label:"Coca-Cola",price:138,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:55,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ33364",recipientName:"Customer 21",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:607,uuid:"LSA000000000000021"},{id:22,items:[{key:"coca-cola",label:"Coca-Cola",price:100,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:95,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ15764",recipientName:"Customer 22",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:490,uuid:"LSA000000000000022"},{id:23,items:[{key:"coca-cola",label:"Coca-Cola",price:130,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:81,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ14864",recipientName:"Customer 23",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:584,uuid:"LSA000000000000023"},{id:24,items:[{key:"coca-cola",label:"Coca-Cola",price:105,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:56,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ38487",recipientName:"Customer 24",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:266,uuid:"LSA000000000000024"},{id:25,items:[{key:"coca-cola",label:"Coca-Cola",price:148,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:91,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ66980",recipientName:"Customer 25",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:626,uuid:"LSA000000000000025"},{id:26,items:[{key:"coca-cola",label:"Coca-Cola",price:134,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:85,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ14351",recipientName:"Customer 26",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:876,uuid:"LSA000000000000026"},{id:27,items:[{key:"coca-cola",label:"Coca-Cola",price:105,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:78,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ35417",recipientName:"Customer 27",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:654,uuid:"LSA000000000000027"},{id:28,items:[{key:"coca-cola",label:"Coca-Cola",price:110,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:51,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ88021",recipientName:"Customer 28",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:314,uuid:"LSA000000000000028"},{id:29,items:[{key:"coca-cola",label:"Coca-Cola",price:120,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:55,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ76116",recipientName:"Customer 29",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:535,uuid:"LSA000000000000029"},{id:30,items:[{key:"coca-cola",label:"Coca-Cola",price:132,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:91,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ76712",recipientName:"Customer 30",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:487,uuid:"LSA000000000000030"},{id:31,items:[{key:"coca-cola",label:"Coca-Cola",price:124,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:52,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ67740",recipientName:"Customer 31",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:528,uuid:"LSA000000000000031"},{id:32,items:[{key:"coca-cola",label:"Coca-Cola",price:108,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:71,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ70558",recipientName:"Customer 32",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:358,uuid:"LSA000000000000032"},{id:33,items:[{key:"coca-cola",label:"Coca-Cola",price:117,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:98,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ43179",recipientName:"Customer 33",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:547,uuid:"LSA000000000000033"},{id:34,items:[{key:"coca-cola",label:"Coca-Cola",price:116,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:93,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ85237",recipientName:"Customer 34",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:557,uuid:"LSA000000000000034"},{id:35,items:[{key:"coca-cola",label:"Coca-Cola",price:138,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:73,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ46461",recipientName:"Customer 35",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:284,uuid:"LSA000000000000035"},{id:36,items:[{key:"coca-cola",label:"Coca-Cola",price:139,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:62,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ95928",recipientName:"Customer 36",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:742,uuid:"LSA000000000000036"},{id:37,items:[{key:"coca-cola",label:"Coca-Cola",price:125,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:92,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ46128",recipientName:"Customer 37",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:651,uuid:"LSA000000000000037"},{id:38,items:[{key:"coca-cola",label:"Coca-Cola",price:125,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:94,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ36624",recipientName:"Customer 38",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:782,uuid:"LSA000000000000038"},{id:39,items:[{key:"coca-cola",label:"Coca-Cola",price:117,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:89,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ93154",recipientName:"Customer 39",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:646,uuid:"LSA000000000000039"},{id:40,items:[{key:"coca-cola",label:"Coca-Cola",price:138,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:71,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ38916",recipientName:"Customer 40",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:698,uuid:"LSA000000000000040"},{id:41,items:[{key:"coca-cola",label:"Coca-Cola",price:133,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:77,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ86636",recipientName:"Customer 41",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:287,uuid:"LSA000000000000041"},{id:42,items:[{key:"coca-cola",label:"Coca-Cola",price:113,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:85,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ92159",recipientName:"Customer 42",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:396,uuid:"LSA000000000000042"},{id:43,items:[{key:"coca-cola",label:"Coca-Cola",price:123,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:64,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ89507",recipientName:"Customer 43",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:379,uuid:"LSA000000000000043"},{id:44,items:[{key:"coca-cola",label:"Coca-Cola",price:125,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:83,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ20324",recipientName:"Customer 44",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:458,uuid:"LSA000000000000044"},{id:45,items:[{key:"coca-cola",label:"Coca-Cola",price:125,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:65,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ94158",recipientName:"Customer 45",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:190,uuid:"LSA000000000000045"},{id:46,items:[{key:"coca-cola",label:"Coca-Cola",price:100,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:65,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ31673",recipientName:"Customer 46",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:530,uuid:"LSA000000000000046"},{id:47,items:[{key:"coca-cola",label:"Coca-Cola",price:140,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:85,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ48914",recipientName:"Customer 47",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:620,uuid:"LSA000000000000047"},{id:48,items:[{key:"coca-cola",label:"Coca-Cola",price:111,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:98,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ92721",recipientName:"Customer 48",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:836,uuid:"LSA000000000000048"},{id:49,items:[{key:"coca-cola",label:"Coca-Cola",price:132,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:90,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ46782",recipientName:"Customer 49",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:576,uuid:"LSA000000000000049"},{id:50,items:[{key:"coca-cola",label:"Coca-Cola",price:119,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:88,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ13490",recipientName:"Customer 50",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:295,uuid:"LSA000000000000050"},{id:51,items:[{key:"coca-cola",label:"Coca-Cola",price:148,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:50,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ51542",recipientName:"Customer 51",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:496,uuid:"LSA000000000000051"},{id:52,items:[{key:"coca-cola",label:"Coca-Cola",price:145,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:99,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ82250",recipientName:"Customer 52",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:442,uuid:"LSA000000000000052"},{id:53,items:[{key:"coca-cola",label:"Coca-Cola",price:118,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:83,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ20591",recipientName:"Customer 53",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:686,uuid:"LSA000000000000053"},{id:54,items:[{key:"coca-cola",label:"Coca-Cola",price:109,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:74,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ46992",recipientName:"Customer 54",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:401,uuid:"LSA000000000000054"},{id:55,items:[{key:"coca-cola",label:"Coca-Cola",price:130,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:64,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ59828",recipientName:"Customer 55",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:258,uuid:"LSA000000000000055"},{id:56,items:[{key:"coca-cola",label:"Coca-Cola",price:144,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:63,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ76445",recipientName:"Customer 56",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:207,uuid:"LSA000000000000056"},{id:57,items:[{key:"coca-cola",label:"Coca-Cola",price:131,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:60,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ65432",recipientName:"Customer 57",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:311,uuid:"LSA000000000000057"},{id:58,items:[{key:"coca-cola",label:"Coca-Cola",price:138,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:88,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ15989",recipientName:"Customer 58",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:540,uuid:"LSA000000000000058"},{id:59,items:[{key:"coca-cola",label:"Coca-Cola",price:122,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:81,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ93664",recipientName:"Customer 59",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:731,uuid:"LSA000000000000059"},{id:60,items:[{key:"coca-cola",label:"Coca-Cola",price:127,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:51,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ53772",recipientName:"Customer 60",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:559,uuid:"LSA000000000000060"},{id:61,items:[{key:"coca-cola",label:"Coca-Cola",price:101,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:66,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ57320",recipientName:"Customer 61",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:268,uuid:"LSA000000000000061"},{id:62,items:[{key:"coca-cola",label:"Coca-Cola",price:122,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:90,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ27736",recipientName:"Customer 62",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:334,uuid:"LSA000000000000062"},{id:63,items:[{key:"coca-cola",label:"Coca-Cola",price:136,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:76,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ24133",recipientName:"Customer 63",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:712,uuid:"LSA000000000000063"},{id:64,items:[{key:"coca-cola",label:"Coca-Cola",price:141,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:84,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ41323",recipientName:"Customer 64",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:732,uuid:"LSA000000000000064"},{id:65,items:[{key:"coca-cola",label:"Coca-Cola",price:117,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:66,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ95766",recipientName:"Customer 65",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:183,uuid:"LSA000000000000065"},{id:66,items:[{key:"coca-cola",label:"Coca-Cola",price:118,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:73,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ82955",recipientName:"Customer 66",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:545,uuid:"LSA000000000000066"},{id:67,items:[{key:"coca-cola",label:"Coca-Cola",price:104,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:67,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ76706",recipientName:"Customer 67",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:483,uuid:"LSA000000000000067"},{id:68,items:[{key:"coca-cola",label:"Coca-Cola",price:122,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:53,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ92141",recipientName:"Customer 68",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:297,uuid:"LSA000000000000068"},{id:69,items:[{key:"coca-cola",label:"Coca-Cola",price:137,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:79,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ17913",recipientName:"Customer 69",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:590,uuid:"LSA000000000000069"},{id:70,items:[{key:"coca-cola",label:"Coca-Cola",price:106,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:98,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ79595",recipientName:"Customer 70",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:612,uuid:"LSA000000000000070"},{id:71,items:[{key:"coca-cola",label:"Coca-Cola",price:134,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:86,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ15338",recipientName:"Customer 71",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:478,uuid:"LSA000000000000071"},{id:72,items:[{key:"coca-cola",label:"Coca-Cola",price:125,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:86,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ29043",recipientName:"Customer 72",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:594,uuid:"LSA000000000000072"},{id:73,items:[{key:"coca-cola",label:"Coca-Cola",price:117,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:83,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ35460",recipientName:"Customer 73",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:683,uuid:"LSA000000000000073"},{id:74,items:[{key:"coca-cola",label:"Coca-Cola",price:116,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:83,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ64048",recipientName:"Customer 74",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:282,uuid:"LSA000000000000074"},{id:75,items:[{key:"coca-cola",label:"Coca-Cola",price:134,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:76,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ79344",recipientName:"Customer 75",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:688,uuid:"LSA000000000000075"},{id:76,items:[{key:"coca-cola",label:"Coca-Cola",price:131,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:80,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ63825",recipientName:"Customer 76",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:604,uuid:"LSA000000000000076"},{id:77,items:[{key:"coca-cola",label:"Coca-Cola",price:143,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:75,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ94010",recipientName:"Customer 77",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:368,uuid:"LSA000000000000077"},{id:78,items:[{key:"coca-cola",label:"Coca-Cola",price:102,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:60,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ80869",recipientName:"Customer 78",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:162,uuid:"LSA000000000000078"},{id:79,items:[{key:"coca-cola",label:"Coca-Cola",price:125,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:55,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ98126",recipientName:"Customer 79",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:345,uuid:"LSA000000000000079"},{id:80,items:[{key:"coca-cola",label:"Coca-Cola",price:127,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:75,quantity:1,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ54410",recipientName:"Customer 80",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:456,uuid:"LSA000000000000080"},{id:81,items:[{key:"coca-cola",label:"Coca-Cola",price:100,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:83,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ99854",recipientName:"Customer 81",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:549,uuid:"LSA000000000000081"},{id:82,items:[{key:"coca-cola",label:"Coca-Cola",price:127,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:83,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ18638",recipientName:"Customer 82",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:674,uuid:"LSA000000000000082"},{id:83,items:[{key:"coca-cola",label:"Coca-Cola",price:143,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:70,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ50956",recipientName:"Customer 83",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:782,uuid:"LSA000000000000083"},{id:84,items:[{key:"coca-cola",label:"Coca-Cola",price:104,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:59,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ39139",recipientName:"Customer 84",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:340,uuid:"LSA000000000000084"},{id:85,items:[{key:"coca-cola",label:"Coca-Cola",price:108,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:99,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ54564",recipientName:"Customer 85",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:405,uuid:"LSA000000000000085"},{id:86,items:[{key:"coca-cola",label:"Coca-Cola",price:104,quantity:2,priceChange:!1},{key:"pepsi",label:"Pepsi",price:79,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ52013",recipientName:"Customer 86",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:366,uuid:"LSA000000000000086"},{id:87,items:[{key:"coca-cola",label:"Coca-Cola",price:149,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:76,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ67711",recipientName:"Customer 87",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:675,uuid:"LSA000000000000087"},{id:88,items:[{key:"coca-cola",label:"Coca-Cola",price:101,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:95,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ57018",recipientName:"Customer 88",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:689,uuid:"LSA000000000000088"},{id:89,items:[{key:"coca-cola",label:"Coca-Cola",price:100,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:60,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ12737",recipientName:"Customer 89",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:340,uuid:"LSA000000000000089"},{id:90,items:[{key:"coca-cola",label:"Coca-Cola",price:131,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:72,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ96029",recipientName:"Customer 90",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:609,uuid:"LSA000000000000090"},{id:91,items:[{key:"coca-cola",label:"Coca-Cola",price:127,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:68,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ18126",recipientName:"Customer 91",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:399,uuid:"LSA000000000000091"},{id:92,items:[{key:"coca-cola",label:"Coca-Cola",price:105,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:99,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ16055",recipientName:"Customer 92",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:711,uuid:"LSA000000000000092"},{id:93,items:[{key:"coca-cola",label:"Coca-Cola",price:142,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:50,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ76269",recipientName:"Customer 93",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:718,uuid:"LSA000000000000093"},{id:94,items:[{key:"coca-cola",label:"Coca-Cola",price:102,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:82,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ66717",recipientName:"Customer 94",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:654,uuid:"LSA000000000000094"},{id:95,items:[{key:"coca-cola",label:"Coca-Cola",price:134,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:83,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ66365",recipientName:"Customer 95",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:300,uuid:"LSA000000000000095"},{id:96,items:[{key:"coca-cola",label:"Coca-Cola",price:125,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:52,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ91286",recipientName:"Customer 96",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:229,uuid:"LSA000000000000096"},{id:97,items:[{key:"coca-cola",label:"Coca-Cola",price:107,quantity:3,priceChange:!1},{key:"pepsi",label:"Pepsi",price:62,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ46141",recipientName:"Customer 97",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:445,uuid:"LSA000000000000097"},{id:98,items:[{key:"coca-cola",label:"Coca-Cola",price:121,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:64,quantity:2,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ55646",recipientName:"Customer 98",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:612,uuid:"LSA000000000000098"},{id:99,items:[{key:"coca-cola",label:"Coca-Cola",price:122,quantity:1,priceChange:!1},{key:"pepsi",label:"Pepsi",price:64,quantity:3,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ16574",recipientName:"Customer 99",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"unpaid",taxPercentage:10,timestamp:1712918870124,total:314,uuid:"LSA000000000000099"},{id:100,items:[{key:"coca-cola",label:"Coca-Cola",price:120,quantity:4,priceChange:!1},{key:"pepsi",label:"Pepsi",price:86,quantity:4,priceChange:!1}],notes:"Auto-generated invoice",recipientId:"BZQ25158",recipientName:"Customer 100",sender:"__personal",senderId:"BZQ08355",senderName:"Nick Walker",status:"paid",taxPercentage:10,timestamp:1712918870124,total:824,uuid:"LSA000000000000100"}],ye=()=>Math.floor(Math.random()*1e4),Ke={totalExpectedIncome:0,graphData:[{date:"May 07, 24",total:ye()},{date:"May 06, 24",total:ye()},{date:"May 05, 24",total:ye()},{date:"May 04, 24",total:ye()},{date:"May 03, 24",total:23692},{date:"May 02, 24",total:275},{date:"May 01, 24",total:ye()},{date:"Apr 30, 24",total:650},{date:"Apr 29, 24",total:150},{date:"Apr 28, 24",total:ye()},{date:"Apr 27, 24",total:ye()},{date:"Apr 26, 24",total:ye()},{date:"Apr 25, 24",total:ye()},{date:"Apr 24, 24",total:ye()},{date:"Apr 23, 24",total:ye()}],totalIncome:8767,totalInvoices:20,recentPayments:ta.splice(0,25)},aa={name:"mechanic",label:"LS Customs",isboss:!0,grade:{level:"4",name:"Manager"},payment:150},ia={identifier:"BZQ08355",fullName:"Nick Walker",taxPercentage:5,money:{cash:371215,bank:1177169,crypto:0}},ra=[{citizenId:"steam:110000100000002",name:"John Smith",id:2},{citizenId:"steam:110000100000004",name:"John Doe",id:4},{citizenId:"steam:110000100000005",name:"Jane Doe",id:5},{citizenId:"steam:110000100000007",name:"Jane Smith",id:7}],na={name:"Law Enforcement",jobIdentifier:"police",create:["-1","__personal"],cancel:["3","4"],acceptFirst:!1,taxPercentage:10,allowCustomItems:!0,defaultInvoiceItems:[{key:"speeding",label:"Speeding",price:100,quantity:1,priceChange:!1,quantityChange:!1},{key:"parking",label:"Parking",price:25,quantity:1,priceChange:!1,quantityChange:!1},{key:"cop-bait",label:"Cop Bait",price:150,quantity:1,priceChange:!1,quantityChange:!1},{key:"illegal-u-turn",label:"Illegal U-turn",price:75,quantity:1,priceChange:!1,quantityChange:!1},{key:"running-red-light",label:"Running Red Light",price:200,quantity:1,priceChange:!1,quantityChange:!1},{key:"failure-to-yield",label:"Failure to Yield",price:80,quantity:1,priceChange:!1,quantityChange:!1},{key:"expired-tags",label:"Expired Tags",price:50,quantity:1,priceChange:!1,quantityChange:!1},{key:"illegal-parking",label:"Illegal Parking",price:40,quantity:1,priceChange:!1,quantityChange:!1},{key:"no-seatbelt",label:"No Seatbelt",price:30,quantity:1,priceChange:!1,quantityChange:!1},{key:"reckless-driving",label:"Reckless Driving",price:250,quantity:1,priceChange:!1,quantityChange:!1},{key:"tailgating",label:"Tailgating",price:90,quantity:1,priceChange:!1,quantityChange:!1},{key:"failure-to-signal",label:"Failure to Signal",price:60,quantity:1,priceChange:!1,quantityChange:!1},{key:"illegal-lane-change",label:"Illegal Lane Change",price:70,quantity:1,priceChange:!1,quantityChange:!1},{key:"driving-without-license",label:"Driving Without License",price:150,quantity:1,priceChange:!1,quantityChange:!1},{key:"expired-insurance",label:"Expired Insurance",price:100,quantity:1,priceChange:!1,quantityChange:!1},{key:"overloading-vehicle",label:"Overloading Vehicle",price:120,quantity:1,priceChange:!1,quantityChange:!1},{key:"littering",label:"Littering",price:50,quantity:1,priceChange:!1,quantityChange:!1},{key:"illegal-horn-use",label:"Illegal Horn Use",price:40,quantity:1,priceChange:!1,quantityChange:!1},{key:"engine-revving",label:"Engine Revving",price:75,quantity:1,priceChange:!1,quantityChange:!1},{key:"wrong-way-driving",label:"Wrong-Way Driving",price:180,quantity:1,priceChange:!1,quantityChange:!1},{key:"blocking-intersection",label:"Blocking Intersection",price:65,quantity:1,priceChange:!1,quantityChange:!1},{key:"distracted-driving",label:"Distracted Driving",price:85,quantity:1,priceChange:!1,quantityChange:!1},{key:"driving-without-headlights",label:"Driving Without Headlights",price:60,quantity:1,priceChange:!1,quantityChange:!1}]},sa={language:"en",showFullName:!0,currencySymbol:"$",allowOverdraft:!0,overdraftLimit:1e3,dateFormat:"DD-MM-YYYY",currencyFormat:"{amount}$",highlightNewInvoiceDuration:30,dateTimeFormat:"DD-MM-YYYY HH:mm",societyFilters:ea,primaryColor:"#1e88e5",secondaryColor:"#673ab7",backgroundMain:"#161a2f",backgroundSecondary:"#0f1327"},oa=G.div.attrs({className:"tgg-create-invoice-form"})`
	display: flex;
	flex-direction: column;
	gap: 0.5em;
	height: 100%;
	padding: 1.5em 0.75em 1em 0.75em;

	.tgg-invoice-header {
		display: flex;
		justify-content: space-between;
		align-items: center;

		gap: 2.5em;

		.tgg-invoice-subtitle {
			font-size: 1.1em;
			font-weight: 600;
			text-align: start;
		}

		.tgg-type-switch-icon {
			display: flex;
			justify-content: center;
			align-items: center;

			transition: transform 0.2s ease-in-out;
			&:hover {
				cursor: pointer;
				transform: scale(1.1);
			}

			svg {
				color: #000;
				font-size: 1.35em;
			}
		}
	}

	.tgg-invoice-body {
		display: flex;
		flex-direction: column;
		gap: 0.25em;
		overflow: hidden;

		.tgg-invoice-row {
			display: flex;
			justify-content: space-between;
			align-items: center;

			gap: 1em;

			.tgg-invoice-label {
				font-size: 1em;
				color: #000;
				font-weight: 600;

				white-space: nowrap;
			}

			.tgg-invoice-value {
				font-size: 1em;
				color: #000;

				white-space: nowrap;
			}

			.tgg-select {
				text-align: end;

				&.ant-select-focused {
					border-bottom: 1px solid rgba(63, 63, 63, 0.05);
				}

				.ant-select-selection-item {
					font-family: 'Poppins', sans-serif;
					font-size: 1.1em;
					color: #000;
				}
			}

			.tgg-add-item-btn {
				display: flex;
				justify-content: center;
				align-items: center;

				transition: transform 0.2s;
				&:hover {
					cursor: pointer;

					transform: scale(1.2);
				}
			}
		}

		.tgg-lighter {
			.tgg-invoice-label,
			.tgg-invoice-value {
				color: rgba(50, 50, 50, 0.75);
			}
		}

		.tgg-items-container {
			display: flex;
			flex-direction: column;

			width: 100%;

			height: 230px;

			overflow-y: auto;
			overflow-x: hidden;

			margin-top: 0.15em;
			padding-right: 0.25em;

			row-gap: 0.5em;

			::-webkit-scrollbar {
				width: 2px;
				height: 2px;
			}

			::-webkit-scrollbar-button {
				width: 0px;
				height: 0px;
			}

			::-webkit-scrollbar-thumb {
				background: #b0b0b0;
				border: 0px none #ffffff;
				border-radius: 50px;
			}

			::-webkit-scrollbar-thumb:hover {
				background: #ffffff;
			}

			::-webkit-scrollbar-thumb:active {
				background: #01e01f;
			}

			::-webkit-scrollbar-track {
				background: #ffffff;
				border: 0px none #ffffff;
				border-radius: 50px;
			}

			::-webkit-scrollbar-track:hover {
				background: #666666;
			}

			::-webkit-scrollbar-track:active {
				background: #797979;
			}

			::-webkit-scrollbar-corner {
				background: transparent;
			}

			#newItemBtn.tgg-disabled {
				opacity: 0.25;
			}

			.tgg-item {
				width: 100%;

				.tgg-remove-item-btn,
				.tgg-add-item-btn {
					display: flex;
					justify-content: center;
					align-items: center;

					width: 10%;

					transition: transform 0.2s;
					&:hover {
						cursor: pointer;
						transform: scale(1.2);
					}
				}

				.tgg-remove-item-btn {
					svg {
						color: #c90000;
					}
				}

				.tgg-add-item-btn {
					svg {
						color: green;
					}
				}

				.ant-space-compact {
					display: flex;
				}

				.ant-input-number-group-addon {
					padding: 0 0.25em;
				}

				.ant-select-selection-item {
					min-width: 100%;
					text-align: start;
				}
			}
		}

		.tgg-summary {
			display: flex;
			flex-direction: column;

			gap: 0;

			.tgg-invoice-label {
				font-size: 1em;
				color: #000;
				font-weight: 600;
				width: 100%;
				text-align: start;
			}

			.tgg-invoice-value {
				font-size: 0.95em;
				color: #000;
				text-align: start;
			}

			.tgg-notes-input {
				margin-bottom: 1em;
				textarea {
					resize: none;
				}
			}
		}

		.tgg-divider-dashed {
			height: 1px;
			width: 100%;
			border-top: 2px dashed rgba(97, 97, 97, 0.5);
			margin: 0.35em 0;
		}
	}
`,ot=({invoiceDetails:e,setInvoiceDetails:a})=>{var ee,Se,_e;const{t:i}=ne(),n=g.useRef(null),[r,c]=g.useState(null),[k,C]=g.useState(),[p,j]=g.useState(0),[m,Z]=g.useState(0),[q,y]=g.useState(0),[o,P]=g.useState(0),[h,d]=g.useState([]),I=N(l=>l.settingsConfig),u=N(l=>l.companyConfig),M=N(l=>l.playerData),f=N(l=>l.menuType),z=N(l=>l.jobInfo);N(l=>l.filters);const $=f===R.Business?u==null?void 0:u.defaultInvoiceItems:[],ce=u==null?void 0:u.allowCustomItems,x=I.currencySymbol,A=I.currencyFormat,E=I.dateFormat,D=N(l=>l.createInvoiceModalOpen),ie=N(l=>l.quickCreateInvoiceVisible),V=_(l=>l.setMenuType),H=_(l=>l.setFlexOasisData);g.useEffect(()=>{if(D===ge.Open||ie){const l=()=>{var Q;const L=u==null?void 0:u.createCompanyInvoice,B=(Q=z==null?void 0:z.grade)==null?void 0:Q.level;return!L||L.length===0?!1:L.includes("-1")||B&&L.includes(B.toString())};Y("billing:get-available-recipients",null,void 0,ra).then(L=>{const B=L.filter(Q=>Q.type==="company"?l():!0);d(B)}),O()?V(R.Business):S()&&V(R.Personal)}},[D,ie,u,z]),g.useEffect(()=>{const l=n.current;l&&(l.scrollTop=l.scrollHeight)},[(ee=e==null?void 0:e.items)==null?void 0:ee.length]),g.useEffect(()=>{var l;((l=e==null?void 0:e.items)==null?void 0:l.length)>0&&X()},[e==null?void 0:e.items,(Se=e==null?void 0:e.items)==null?void 0:Se.length]),g.useEffect(()=>{const l=f==R.Personal?(M==null?void 0:M.taxPercentage)??0:(u==null?void 0:u.taxPercentage)??0;a({...e,sender:f==R.Personal?"__personal":(z==null?void 0:z.name)??"",senderCompanyName:f==R.Personal?"":z==null?void 0:z.label,items:[],total:0,notes:"",recipientId:void 0,recipientName:"",recipientType:"player",recipientCompany:void 0,taxPercentage:l}),j(0),y(0),Z(0),P(l)},[f]);const X=()=>{var Q;let l=0,L=0,B=0;(Q=e==null?void 0:e.items)==null||Q.forEach(U=>{l+=U.price*U.quantity}),o&&o>0&&(L=l*(o/100),j(+(l==null?void 0:l.toFixed(2))),y(+(L==null?void 0:L.toFixed(2)))),B=l+L,Z(+(B==null?void 0:B.toFixed(2))),a({...e,total:+(l==null?void 0:l.toFixed(2))})},T=()=>de().format(E),ve=(l,L,B,Q,U,Te)=>{let Ie=[...e.items];const ct=l??(r==null?void 0:r.key)??"",Fe=Ie.findIndex(Oe=>Oe.key===ct);if(Fe!==-1){if(!Ie[Fe].quantityChange){H({status:!0,message:"itemQuantityDisabled"});return}Ie[Fe].quantity+=1}else{const Oe={key:l??(r==null?void 0:r.key)??"",label:L??(r==null?void 0:r.label)??"",price:B??(r==null?void 0:r.price)??-1,quantity:Q??(r==null?void 0:r.quantity)??1,priceChange:U??(r==null?void 0:r.priceChange)??!1,quantityChange:Te??(r==null?void 0:r.quantityChange)??!1};Ie=[...Ie,Oe]}a({...e,items:Ie}),c(null)},ue=l=>{var B;if(((B=e==null?void 0:e.items)==null?void 0:B.length)===1)return;const L=[...e.items];L.splice(l,1),a({...e,items:L})},je=(l,L)=>{const B=[...e.items],Q=$==null?void 0:$.find(U=>U.key===l);Q&&(B[L]={key:Q.key,label:Q.label,price:Q.price,quantity:Q.quantity,priceChange:Q.priceChange},a({...e,items:B}))},he=(l,L)=>{const B=[...e.items];B[L].price=l,a({...e,items:B})},b=(l,L)=>{const B=[...e.items];B[L].quantity=l,a({...e,items:B})},F=l=>{const L=h.find(Q=>Q.citizenId===l||Q.companyId===l);if(!L)return;const B=L.type==="company";a({...e,recipientId:B?void 0:L.citizenId,recipientName:L.name,recipientType:B?"company":"player",recipientCompany:B?L.companyId||L.citizenId:void 0})},le=l=>{const L=l;C(!1);const B=$==null?void 0:$.find(Q=>Q.key===L);if(!B)c(l);else{const Q=e.items.find(U=>U.key===L);if(Q){if(!Q.quantityChange){H({status:!0,message:"itemQuantityDisabled"});return}const U=[...e.items],Te=U.findIndex(Ie=>Ie.key===L);U[Te].quantity+=1,a({...e,items:U})}else ve(B.key,B.label,B.price,B.quantity,B.priceChange,B.quantityChange)}},s=l=>{const L=$==null?void 0:$.find(B=>B.key===l);return(L==null?void 0:L.price)??""},S=()=>{const l=u==null?void 0:u.create;return!!(l!=null&&l.includes("__personal"))},O=()=>{var B;const l=u==null?void 0:u.create,L=(B=z==null?void 0:z.grade)==null?void 0:B.level;if(!l||l.length===0)return!1;if(l.includes("-1"))return!0;if(L!=null){const Q=L.toString();if(l.includes(Q))return!0}return!1};return t.jsxs(oa,{children:[t.jsx("div",{className:"tgg-invoice-header",children:t.jsx("div",{className:"tgg-invoice-subtitle",children:f===R.Personal?i("invoice.personalInovice"):z==null?void 0:z.label})}),t.jsxs("div",{className:"tgg-invoice-body",children:[t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.status"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:i("invoice.draftStatus")})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.date"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:T()})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.from"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:M==null?void 0:M.fullName})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.to"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:t.jsx(Me,{className:"tgg-select",showSearch:!0,size:"small",variant:"borderless",style:{width:200},placeholder:i("invoice.selectRecipient"),optionFilterProp:"children",value:(e==null?void 0:e.recipientType)==="company"?e==null?void 0:e.recipientCompany:(e==null?void 0:e.recipientId)||null,filterOption:(l,L)=>{var B;return(B=((L==null?void 0:L.label)??"").toLowerCase())==null?void 0:B.includes(l.toLowerCase())},filterSort:(l,L)=>((l==null?void 0:l.label)??"").toLowerCase().localeCompare(((L==null?void 0:L.label)??"").toLowerCase()),onSelect:l=>F(l),onDropdownVisibleChange:l=>{if(l){const L=()=>{var U;const B=u==null?void 0:u.createCompanyInvoice,Q=(U=z==null?void 0:z.grade)==null?void 0:U.level;return!B||B.length===0?!1:B.includes("-1")||Q&&B.includes(Q.toString())};Y("billing:get-available-recipients",null,void 0,[]).then(B=>{const Q=B.filter(U=>U.type==="company"?L():!0);d(Q)})}},options:h&&h.map(l=>({value:l.type==="company"&&l.companyId||l.citizenId,label:l.type==="company"?`🏢 ${l.name}`:I.showFullName?l.name:l.id.toString()}))})})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.items"),":"]}),t.jsx("div",{className:"tgg-invoice-value"})]}),t.jsxs("div",{className:"tgg-items-container",ref:n,children:[(_e=e==null?void 0:e.items)==null?void 0:_e.map((l,L)=>{var B;return t.jsx("div",{className:"tgg-item",children:t.jsxs(We.Compact,{children:[((B=e==null?void 0:e.items)==null?void 0:B.length)>1&&t.jsx("div",{className:"tgg-remove-item-btn",onClick:()=>ue(L),children:t.jsx(ut,{})}),t.jsx(Me,{showSearch:!0,size:"small",filterOption:(Q,U)=>((U==null?void 0:U.label)??"").includes(Q),dropdownStyle:{width:250},onSelect:Q=>je(Q,L),style:{width:"50%",minWidth:"50%"},value:l.key,optionRender:Q=>{var U;return t.jsx("div",{children:`${Q.label} - ${oe(s(((U=Q==null?void 0:Q.value)==null?void 0:U.toString())??""),A)}`})},options:$==null?void 0:$.map(Q=>({value:Q.key,label:Q.label}))}),t.jsx(Qe,{size:"small",min:1,maxLength:5,addonAfter:"x",disabled:!l.quantityChange,value:l==null?void 0:l.quantity,onChange:Q=>b(Q??1,L),style:{minWidth:"15%"},controls:!1}),t.jsx(Qe,{size:"small",min:-1,maxLength:16,addonAfter:x,disabled:!l.priceChange,value:l==null?void 0:l.price,onChange:Q=>he(Q??-1,L),style:{minWidth:"25%"},controls:!1})]})},l.key+L)}),t.jsx("div",{className:"tgg-item",children:t.jsxs(We.Compact,{children:[t.jsx("div",{id:"newItemBtn",className:"tgg-add-item-btn",children:t.jsx(Ge,{})}),t.jsx(Me,{showSearch:!0,size:"small",onSelect:l=>le(l),value:r,dropdownStyle:{width:250},style:{width:"50%",minWidth:"50%"},options:$==null?void 0:$.map(l=>({value:l.key,label:`${l.label}`})),optionRender:l=>t.jsx("div",{children:`${l.label} - ${oe(s(l.key.toString()),A)}`}),onDropdownVisibleChange:l=>C(l),open:k,dropdownRender:l=>t.jsxs(t.Fragment,{children:[(ce||f===R.Personal)&&t.jsxs(t.Fragment,{children:[t.jsxs(We,{style:{padding:"0 8px 4px"},children:[t.jsx(ht,{variant:"borderless",placeholder:i("invoice.enterItem"),value:r==null?void 0:r.key,onChange:L=>{c({key:L.target.value,label:L.target.value,quantity:1,price:-1,priceChange:!0,quantityChange:!0})},onKeyDown:L=>L.stopPropagation()}),t.jsx(tt,{disabled:!(r!=null&&r.key),type:"dashed",icon:t.jsx(Ge,{}),onClick:()=>{C(!1),ve()}})]}),t.jsx(yt,{style:{margin:"8px 0"}})]}),l]})}),t.jsx(Qe,{size:"small",min:1,maxLength:5,addonAfter:"x",value:r==null?void 0:r.quantity,onChange:l=>{!l||!(r!=null&&r.price)||c({price:(r==null?void 0:r.price)*l,quantity:l,label:(r==null?void 0:r.label)??"",key:(r==null?void 0:r.key)??"",priceChange:(r==null?void 0:r.priceChange)||!1})},style:{minWidth:"15%"},controls:!1}),t.jsx(Qe,{size:"small",min:-1,maxLength:16,addonAfter:x,value:r==null?void 0:r.price,onChange:l=>{l&&c({price:l,label:(r==null?void 0:r.label)??"",key:(r==null?void 0:r.key)??"",quantity:(r==null?void 0:r.quantity)??1,priceChange:(r==null?void 0:r.priceChange)||!1})},style:{minWidth:"25%"},controls:!1})]})})]}),t.jsxs("div",{className:"tgg-invoice-row tgg-summary",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.notes"),":"]}),t.jsx(bt,{className:"tgg-notes-input",count:{show:!0,max:70},value:e==null?void 0:e.notes,onChange:l=>{a({...e,notes:l.target.value})},variant:"borderless",rows:2,placeholder:i("invoice.notesPlaceholder"),maxLength:70})]}),t.jsx("div",{className:"tgg-divider-dashed"}),o&&o>0&&t.jsxs(t.Fragment,{children:[t.jsxs("div",{className:"tgg-invoice-row tgg-lighter",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.subTotal"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:oe(pe(p),A)})]}),t.jsxs("div",{className:"tgg-invoice-row tgg-lighter",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.vat"),"(",o,"%):"]}),t.jsx("div",{className:"tgg-invoice-value",children:oe(pe(q),A)})]})]}),t.jsxs("div",{className:"tgg-invoice-row",children:[t.jsxs("div",{className:"tgg-invoice-label",children:[i("invoice.total"),":"]}),t.jsx("div",{className:"tgg-invoice-value",children:oe(pe(m),A)})]})]})]})},la=G.div.attrs({className:"tgg-quick-create-invoice"})`
	position: fixed;
	top: 0;
	left: 0;

	width: 100%;
	height: 100%;

	display: flex;
	justify-content: end;
	align-items: center;

	padding: 0 12em;

	overflow: hidden;

	z-index: 999999;

	pointer-events: none;

	.tgg-invoice-popup {
		position: absolute;
		bottom: -100%;
		transition: bottom 0.5s ease-in-out;
		pointer-events: auto;
	}

	.tgg-visible {
		bottom: 40px;
	}
`,ca=ft`
	.ant-select-dropdown {
		z-index: 10000000 !important;
	}
`,da=()=>{const{t:e}=ne(),a=N(d=>d.quickCreateInvoiceVisible),i=N(d=>d.companyConfig),n=N(d=>d.playerData),r=N(d=>d.menuType),c=N(d=>d.jobInfo),k=N(d=>d.filters),[C,p]=g.useState({items:[],notes:"",recipientId:"",recipientName:"",sender:r==R.Personal?"__personal":(c==null?void 0:c.name)??"",senderId:(n==null?void 0:n.identifier)??"",senderName:(n==null?void 0:n.fullName)??"",taxPercentage:(i==null?void 0:i.taxPercentage)??0,total:0}),j=_(d=>d.setCustomModal);_(d=>d.setMenuType);const m=_(d=>d.setFilters),Z=_(d=>d.setQuickCreateInvoiceVisible),q=_(d=>d.setFlexOasisData);g.useEffect(()=>{a&&p({items:[],notes:"",recipientId:"",recipientName:"",sender:r==R.Personal?"__personal":(c==null?void 0:c.name)??"",senderId:(n==null?void 0:n.identifier)??"",senderName:(n==null?void 0:n.fullName)??"",taxPercentage:(i==null?void 0:i.taxPercentage)??0,total:0})},[a,r,c,n,i]),g.useEffect(()=>{if(!a)return;const d=I=>{["Escape"].includes(I.code)&&(Pe()||(I.preventDefault(),h()))};return window.addEventListener("keyup",d),()=>window.removeEventListener("keyup",d)},[a]);const y=()=>{const d={...C};d.items=d.items.filter(I=>I.price!==-1),p(d),j(null)},o=()=>C.items.some(d=>d.price===-1),P=()=>{if(o()){j({visible:!0,onOk:()=>y(),onCancel:()=>j(null),bodyText:e("invoice.hasDirtyItems")});return}C.sender!=="__personal"&&(C.senderCompanyName=c==null?void 0:c.label),Y("billing:invoice:create",C,void 0,ze[69]).then(I=>{let u="";if(I!=null&&I.id){const M={...k,society:"byMe",status:v.Unpaid,orderBy:Ne.Newest,dateRange:{dateFrom:"",dateTo:""}};I.sender===K.Personal?m({...M,type:K.Personal}):m({...M,type:K.Society}),Z(!1),Y("billing:close-quick-create-invoice"),u="invoiceCreated"}else u="invoiceCreateFailed";q({status:!0,message:u})})},h=()=>{Z(!1),Y("billing:close-quick-create-invoice")};return t.jsxs(t.Fragment,{children:[t.jsx(ca,{}),t.jsx(la,{children:t.jsx("div",{className:`tgg-invoice-popup${a?" tgg-visible":""}`,children:t.jsx(Ze,{type:W.Create,body:t.jsx(ot,{invoiceDetails:C,setInvoiceDetails:p}),footer:t.jsx(st,{handleCancelInvoice:h,invoiceDetails:C,handleCreateInvoice:P})})})})]})},ke=(e,a)=>{const i=g.useRef(Ft);g.useEffect(()=>{i.current=a},[a]),g.useEffect(()=>{const n=r=>{const{action:c,data:k}=r.data;i.current&&c===e&&i.current(k)};return window.addEventListener("message",n),()=>window.removeEventListener("message",n)},[e])},Re=(e,a=0)=>{for(const i of e)(Pe()||i.internal)&&setTimeout(()=>{!i.internal&&console.info(`[DEBUG] Dispatching event: ${i.action}`),window.dispatchEvent(new MessageEvent("message",{data:{action:i.action,data:i.data}}))},a)},pa=()=>{const[e,a]=g.useState(()=>typeof window>"u"?"#1e88e5":getComputedStyle(document.documentElement).getPropertyValue("--color-primary").trim()||"#1e88e5");g.useEffect(()=>{const n=()=>{if(typeof window<"u"){const c=getComputedStyle(document.documentElement).getPropertyValue("--color-primary").trim()||"#1e88e5";a(c)}};n();const r=new MutationObserver(n);return document.documentElement&&r.observe(document.documentElement,{attributes:!0,attributeFilter:["style"]}),()=>r.disconnect()},[]);const i=e;return t.jsxs("svg",{width:"64",height:"64",viewBox:"0 0 512 512",children:[t.jsx("path",{fill:e,d:"M121 135c0 74.443 60.557 135 135 135s135-60.557 135-135S330.443 0 256 0 121 60.557 121 135z","data-original":"#45c1f1"}),t.jsx("path",{fill:i,d:"M391 135C391 60.557 330.443 0 256 0v270c74.443 0 135-60.557 135-135z","data-original":"#44a4ec"}),t.jsx("path",{fill:e,d:"M31 497c0 8.291 6.709 15 15 15h420c8.291 0 15-6.709 15-15 0-107.52-87.48-197-195-197h-60c-107.52 0-195 89.48-195 197z","data-original":"#45c1f1"}),t.jsx("path",{fill:i,d:"M286 300h-30v212h210c8.291 0 15-6.709 15-15 0-107.52-87.48-197-195-197z","data-original":"#44a4ec"})]})},De=()=>t.jsx("svg",{width:"41",height:"38",viewBox:"0 0 41 38",fill:"currentColor",children:t.jsx("path",{d:"M34.551 41.2117L40.7154 12.2104C41.1448 10.19 40.5332 6.9189 37.0866 6.18631L10.2784 0.488051C9.80376 0.349419 8.03125 -0.0426909 6.03523 1.0863C3.65737 2.4316 1.97605 5.35154 1.03738 9.76765L0.747382 11.132L6.20218 12.2914L0.431844 39.4387C0.0873389 41.0595 0.260907 42.3918 0.948594 43.3971C1.49228 44.1921 2.19391 44.5389 2.61533 44.6841L2.61064 44.7062L31.1981 50.7826C36.5917 51.9291 39.1964 46.6817 39.8202 43.7468L40.1109 42.3794L34.551 41.2117ZM4.09197 8.99162C4.98919 5.7246 6.228 4.27857 7.20181 3.63984C7.52324 4.02674 7.77236 4.9043 7.41484 6.58628L6.78204 9.56341L4.09197 8.99162ZM6.77245 36.8009C5.8598 41.0946 4.31789 42.1097 3.49429 42.0357C3.16261 41.8987 2.88659 41.2981 3.15876 40.0177L10.1416 7.16588C10.4909 5.52246 10.4082 4.25356 10.0997 3.29109L36.5069 8.91371C38.3027 9.29542 38.0932 11.0965 37.9874 11.6306L31.8214 40.6392L7.06154 35.4409L6.77245 36.8009ZM31.778 48.0546L7.24732 42.8405C7.96361 41.9295 8.64069 40.6161 9.16928 38.7312L36.6793 44.5077C36.0451 46.1551 34.5978 48.654 31.778 48.0546ZM25.7918 12.7551L34.3095 14.5656L33.7297 17.293L25.2121 15.4825L25.7918 12.7551ZM24.5036 18.8159L33.0212 20.6264L32.4416 23.3532L23.924 21.5427L24.5036 18.8159ZM23.2455 24.7346L31.7631 26.5451L31.1835 29.2719L22.6659 27.4614L23.2455 24.7346ZM10.2996 28.4806L30.5586 32.7868L29.9789 35.5142L9.71988 31.208L10.2996 28.4806ZM20.4945 19.9379C20.4208 20.285 20.294 20.6227 20.1177 20.9403C19.9367 21.2683 19.6864 21.558 19.375 21.8009C19.0674 22.0413 18.6912 22.2281 18.2582 22.3542C17.8982 22.4587 17.4829 22.5105 17.0216 22.5078L16.598 24.5007L13.9807 23.9444L14.3891 22.0231C13.7308 21.8096 13.1902 21.5718 12.7796 21.3157C12.319 21.0297 11.988 20.8052 11.7684 20.6286L11.5491 20.4534L12.9576 18.2419L13.2294 18.4532C13.5471 18.7011 13.944 18.9525 14.4084 19.1996C14.8628 19.4427 15.3679 19.6242 15.9096 19.7394C16.6667 19.9003 16.981 19.8334 17.1006 19.7795C17.2844 19.697 17.3918 19.5561 17.4386 19.3357C17.4686 19.195 17.4628 19.0747 17.4207 18.9686C17.3725 18.8464 17.2845 18.7215 17.1598 18.5977C17.0189 18.4571 16.8286 18.3053 16.5935 18.1472C16.3451 17.9793 16.0561 17.795 15.7272 17.594C15.3957 17.3866 15.0733 17.1671 14.7663 16.9381C14.446 16.6992 14.1619 16.4258 13.9219 16.1253C13.672 15.8111 13.4921 15.4505 13.3862 15.0518C13.2777 14.6475 13.277 14.1874 13.3839 13.6842C13.4646 13.3047 13.5992 12.9451 13.7833 12.6176C13.9716 12.2828 14.2176 11.989 14.5151 11.7451C14.8148 11.4999 15.1784 11.3123 15.5951 11.1878C15.9333 11.0864 16.3135 11.0315 16.7276 11.0242L17.105 9.24862L19.7223 9.80493L19.364 11.4906C19.8031 11.6396 20.1891 11.7984 20.5149 11.963C20.9017 12.1597 21.2127 12.3429 21.4382 12.5098L21.6501 12.6655L20.4712 15.0308L20.1739 14.8223C19.8719 14.6117 19.5052 14.4045 19.0849 14.209C18.6686 14.0156 18.2124 13.8655 17.7295 13.7628C17.1835 13.6468 16.9097 13.698 16.7762 13.7604C16.604 13.8422 16.5102 13.9585 16.4716 14.1397C16.4472 14.2548 16.4479 14.3566 16.4743 14.4403C16.5018 14.5274 16.562 14.6176 16.6536 14.7074C16.7676 14.8212 16.9179 14.9414 17.1004 15.0672C17.2944 15.2019 17.5312 15.352 17.8096 15.5199C18.2539 15.798 18.6603 16.0865 19.0231 16.3779C19.3976 16.6808 19.7146 17.0073 19.9656 17.3491C20.2262 17.7033 20.4085 18.0977 20.5082 18.5226C20.6067 18.9529 20.6029 19.4281 20.4945 19.9379Z",fill:"currentColor"})}),ga=()=>{const[e,a]=g.useState(()=>typeof window>"u"?"#1e88e5":getComputedStyle(document.documentElement).getPropertyValue("--color-primary").trim()||"#1e88e5");return g.useEffect(()=>{const i=()=>{if(typeof window<"u"){const r=getComputedStyle(document.documentElement).getPropertyValue("--color-primary").trim()||"#1e88e5";a(r)}};i();const n=new MutationObserver(i);return document.documentElement&&n.observe(document.documentElement,{attributes:!0,attributeFilter:["style"]}),()=>n.disconnect()},[]),t.jsx("svg",{width:"25",height:"23",viewBox:"0 0 25 23",fill:"none",xmlns:"http://www.w3.org/2000/svg",children:t.jsx("path",{d:"M24 3.55556H21.4444M24 11.2222H17.6111M24 18.8889H17.6111M6.11111 21.4444V13.2171C6.11111 12.9513 6.11111 12.8184 6.08502 12.6913C6.06188 12.5786 6.0236 12.4695 5.97122 12.3669C5.91217 12.2513 5.82916 12.1476 5.66311 11.9399L1.448 6.67111C1.28195 6.46356 1.19894 6.35978 1.13989 6.24422C1.08751 6.14169 1.04923 6.03255 1.02609 5.91978C1 5.79266 1 5.65976 1 5.39396V3.04444C1 2.32882 1 1.97101 1.13926 1.69768C1.26178 1.45725 1.45725 1.26178 1.69768 1.13927C1.97101 1 2.32882 1 3.04444 1H14.2889C15.0046 1 15.3624 1 15.6357 1.13927C15.8761 1.26178 16.0715 1.45725 16.1941 1.69768C16.3333 1.97101 16.3333 2.32882 16.3333 3.04444V5.39396C16.3333 5.65976 16.3333 5.79266 16.3073 5.91978C16.2841 6.03255 16.2458 6.14169 16.1934 6.24422C16.1344 6.35978 16.0513 6.46356 15.8853 6.67111L11.6702 11.9399C11.5042 12.1476 11.4212 12.2513 11.3621 12.3669C11.3098 12.4695 11.2714 12.5786 11.2483 12.6913C11.2222 12.8184 11.2222 12.9513 11.2222 13.2171V17.6111L6.11111 21.4444Z",stroke:e,strokeWidth:"2",strokeLinecap:"round",strokeLinejoin:"round"})})},ma=()=>t.jsx("svg",{width:"17",height:"17",viewBox:"0 0 17 17",fill:"none",xmlns:"http://www.w3.org/2000/svg",children:t.jsx("path",{d:"M16.7688 14.7001L13.4582 11.3895C13.3088 11.2401 13.1062 11.1571 12.8937 11.1571H12.3525C13.2689 9.98491 13.8135 8.51058 13.8135 6.90676C13.8135 3.09144 10.7221 0 6.90676 0C3.09144 0 0 3.09144 0 6.90676C0 10.7221 3.09144 13.8135 6.90676 13.8135C8.51058 13.8135 9.98491 13.2689 11.1571 12.3525V12.8937C11.1571 13.1062 11.2401 13.3088 11.3895 13.4582L14.7001 16.7688C15.0122 17.0809 15.517 17.0809 15.8258 16.7688L16.7655 15.8291C17.0776 15.517 17.0776 15.0122 16.7688 14.7001ZM6.90676 11.1571C4.55912 11.1571 2.65644 9.25771 2.65644 6.90676C2.65644 4.55912 4.5558 2.65644 6.90676 2.65644C9.25439 2.65644 11.1571 4.5558 11.1571 6.90676C11.1571 9.25439 9.25771 11.1571 6.90676 11.1571Z",fill:"currentColor"})}),ua=()=>t.jsx("svg",{width:"75",height:"75",viewBox:"0 0 512.018 512.018",children:t.jsx("g",{children:t.jsx("path",{d:"M6.98 256.673c-5.504 2.027-8.341 8.128-6.336 13.653l6.699 18.432L58.35 237.75 6.98 256.673zM55.257 420.513l30.72 84.48a10.57 10.57 0 0 0 5.525 6.016 10.73 10.73 0 0 0 4.501 1.003c1.259 0 2.496-.213 3.691-.661l33.899-12.501-78.336-78.337zM511.364 348.385l-35.157-96.661-84.373 84.373 41.813-15.403c5.483-2.091 11.669.768 13.696 6.315 2.048 5.525-.789 11.669-6.315 13.696l-53.12 19.584a10.617 10.617 0 0 1-3.691.661c-4.331 0-8.427-2.667-10.005-6.976-.021-.064 0-.128-.021-.192l-89.408 89.408 220.245-81.152c5.525-2.026 8.362-8.128 6.336-13.653zM508.889 173.793 338.222 3.126c-4.16-4.16-10.923-4.16-15.083 0l-320 320c-4.16 4.16-4.16 10.923 0 15.083l170.667 170.667a10.56 10.56 0 0 0 7.531 3.136c2.731 0 5.461-1.045 7.552-3.115l320-320a10.7 10.7 0 0 0 0-15.104zm-384 121.771L82.222 338.23a10.716 10.716 0 0 1-15.104 0c-4.16-4.16-4.16-10.923 0-15.083l42.667-42.667c4.16-4.16 10.923-4.16 15.083 0 4.16 4.161 4.181 10.902.021 15.084zm184.213 13.546c-7.552 7.552-17.813 11.179-29.227 11.179-18.859 0-40.896-9.877-59.328-28.331-13.483-13.483-22.955-29.611-26.645-45.397-4.096-17.6-.725-32.917 9.493-43.157 10.219-10.24 25.536-13.611 43.157-9.493 15.787 3.691 31.915 13.141 45.397 26.645 29.633 29.61 37.185 68.522 17.153 88.554zm135.787-120.213-42.667 42.667a10.716 10.716 0 0 1-15.104 0c-4.16-4.16-4.16-10.923 0-15.083l42.667-42.667c4.16-4.16 10.923-4.16 15.083 0s4.181 10.902.021 15.083z",fill:"currentColor",opacity:"1"})})}),ha=()=>t.jsx("svg",{width:"512",height:"512",viewBox:"0 0 512 512",children:t.jsx("g",{children:t.jsxs("g",{"data-name":"Layer 2",children:[t.jsx("circle",{cx:"256",cy:"256",r:"256",fill:"#00a1f5"}),t.jsx("path",{fill:"#ffffff",d:"M375.54 143.39a25.88 25.88 0 0 0-10.3-21.18c-12.38-8.34-24.22-22.32-38.57-22.34-13.82-.12-24.27 12.75-35.32 19.78-11-7-21.53-19.88-35.33-19.75-7-.23-14.19 3.52-20 8.3-5 3.58-10.21 7.91-15.35 11.43-5.09-3.45-10.22-7.78-15.19-11.31-5.72-4.76-12.82-8.67-20.15-8.43-10.55-.43-19 7.73-27 13.62-11.22 8-22.44 15.4-21.87 31v222.68c0 9.81 3.86 17.65 11.51 23.29 4.77 3.52 9.59 7.16 14.25 10.68 6.64 5.39 14.56 11 23.11 10.69 13.91.14 24.26-12.72 35.37-19.76 11.14 7.07 21.36 19.84 35.35 19.75 7 .2 14-3.38 19.53-8 5.57-3.87 11.11-8.82 16.88-12.45 36.5 20.87 33.3 20 69.25-.66 9-5.2 13.83-13.47 13.83-23.89.03-72.35.03-147.53 0-223.45zm-172.17 46c31.11-.06 61 0 91.87 0 11.46-.05 26.57-2.06 27.29 13.53.11 7.86-6.57 13.69-14.38 13.56h-81.42c-12.64-1.11-35.86 5.31-37.22-12.89a13.58 13.58 0 0 1 13.86-14.23zm105 133H203.9a14.85 14.85 0 0 1-10.64-4.14c-8.38-8.45-1.88-23.54 10.62-22.93h104.26c7.7 0 13.6 5 14.35 12.14 1.01 7.95-6.05 15.36-14.09 14.92zm0-53c-28.74-.06-76 0-104.77 0-18.16.07-18.9-26.1-.85-27 8.06-.16 48.33.06 57.2 0h48.41c5.79 0 10.16 2.58 12.65 7.45 4.93 8.77-2.42 20.09-12.61 19.57z"})]})})}),ya=()=>t.jsxs("svg",{xmlns:"http://www.w3.org/2000/svg",width:"512",height:"512",enableBackground:"new 0 0 512 512",viewBox:"0 0 682.667 682.667",children:[t.jsx("defs",{children:t.jsx("clipPath",{id:"a",clipPathUnits:"userSpaceOnUse",children:t.jsx("path",{d:"M0 512h512V0H0z","data-original":"currentColor"})})}),t.jsxs("g",{fill:"none",stroke:"currentColor",strokeLinecap:"round",strokeLinejoin:"round",strokeMiterlimit:"10",strokeWidth:"15",clipPath:"url(#a)",transform:"matrix(1.33333 0 0 -1.33333 0 682.667)",children:[t.jsx("path",{d:"M167.348 274.711h-52.07a12.717 12.717 0 01-12.08-8.741L63.977 146.834M448.023 146.834L408.801 265.97a12.717 12.717 0 01-12.08 8.741h-51.548M496.353 83.707v59.15c0 1.351-.215 2.694-.638 3.977l-34.349 104.337","data-original":"currentColor"}),t.jsx("path",{d:"M206.73 351.223H92.775a12.718 12.718 0 01-12.08-8.741l-64.41-195.648a12.697 12.697 0 01-.638-3.976v-39.151M449.791 286.33l-18.486 56.153a12.72 12.72 0 01-12.08 8.741H306.757","data-original":"currentColor"}),t.jsx("path",{d:"M15.648 52.407V20.218c0-7.024 5.694-12.718 12.718-12.718h455.269c7.024 0 12.718 5.694 12.718 12.718v110.364c0 7.024-5.694 12.718-12.718 12.718h-93.901c-4.86 0-9.295-2.77-11.428-7.137l-18.452-37.78a12.714 12.714 0 00-11.427-7.137H163.574c-4.86 0-9.294 2.769-11.427 7.137l-18.452 37.78a12.719 12.719 0 01-11.428 7.137H28.366c-7.024 0-12.718-5.694-12.718-12.718V89.433M53.912 42.107h27.446M53.912 65.536h27.446M408.802 265.97v85.252M103.198 265.97v85.252M273.298 253.356c-4.614 3.938-11.087 6.409-18.278 6.431-7.191.021-13.679-2.411-18.316-6.322M297.351 287.937h.09M214.559 287.937h.089M297.342 287.937h.089","data-original":"currentColor"}),t.jsx("path",{d:"M274.05 194.118c39.399 8.311 68.974 43.271 68.974 85.144 0 48.062-38.961 87.024-87.023 87.024s-87.024-38.962-87.024-87.024c0-41.543 29.112-76.282 68.047-84.942M216.33 504.5l-22.732-22.732M216.33 481.768L193.598 504.5M108.113 432.485c0 14.771 11.974 26.745 26.745 26.745s26.745-11.974 26.745-26.745-11.974-26.746-26.745-26.746-26.745 11.975-26.745 26.746M385.96 430.903l-22.732-22.732M385.96 408.17l-22.732 22.732M255.61 411.502l.066 22.333M222.304 401.983L210.7 421.357M300.579 420.987l-11.72-19.31M345.704 473.753c0-11.733-9.511-21.244-21.244-21.244s-21.244 9.511-21.244 21.244 9.511 21.244 21.244 21.244 21.244-9.511 21.244-21.244z","data-original":"currentColor"})]})]}),ba=()=>t.jsx("svg",{width:"48",height:"48",viewBox:"0 0 32 32",children:t.jsxs("g",{children:[t.jsx("path",{d:"M27.01 2.5H4.99A2.493 2.493 0 0 0 2.5 4.99V29a.5.5 0 0 0 .78.414l2.47-1.669 2.466 1.669a.503.503 0 0 0 .561 0l2.469-1.669 2.473 1.67c.169.114.39.114.56 0l2.469-1.669 2.475 1.67a.5.5 0 0 0 .559 0l2.48-1.67 2.48 1.67a.498.498 0 0 0 .779-.414V13.243l.721-.485 2.48 1.67a.5.5 0 0 0 .779-.414V4.99A2.494 2.494 0 0 0 27.01 2.5zm-2.49 2.49v23.07l-1.98-1.333a.5.5 0 0 0-.559 0l-2.48 1.67-2.476-1.67a.501.501 0 0 0-.56 0l-2.468 1.669-2.473-1.67a.501.501 0 0 0-.56 0l-2.469 1.669-2.465-1.668a.501.501 0 0 0-.56 0L3.5 28.059V4.99c0-.822.668-1.49 1.49-1.49h20.026a2.481 2.481 0 0 0-.496 1.49zm3.98 8.084-1.98-1.333a.5.5 0 0 0-.559 0l-.441.297V4.99a1.491 1.491 0 0 1 2.98 0z",fill:"#ffffff"}),t.jsx("path",{d:"M6.553 8.901h14.914a.5.5 0 0 0 0-1H6.553a.5.5 0 0 0 0 1zM6.553 13.265h14.914a.5.5 0 0 0 0-1H6.553a.5.5 0 0 0 0 1zM6.553 17.628h14.914a.5.5 0 0 0 0-1H6.553a.5.5 0 0 0 0 1zM6.553 21.991h14.914a.5.5 0 0 0 0-1H6.553a.5.5 0 0 0 0 1z",fill:"#ffffff"})]})}),fa=()=>t.jsx("svg",{width:"48",height:"48",viewBox:"0 0 512 512",children:t.jsx("g",{children:t.jsx("path",{d:"M464.299 214.018c22.908 0 41.548-18.635 41.548-41.549v-43.822a8.06 8.06 0 0 0-8.061-8.061h-58.91V56.752c0-22.908-18.639-41.547-41.547-41.547H80.199c-22.367 0-40.557 18.191-40.557 40.561V437.12c-.034 13.992-11.439 25.404-25.429 25.449h-.022c-4.448.014-8.044 3.623-8.038 8.064a8.058 8.058 0 0 0 8.061 8.055h45.523a8.02 8.02 0 0 0 3.833-.973l22.411-12.119 11.498 10.883a8.067 8.067 0 0 0 5.547 2.209 8.033 8.033 0 0 0 3.898-1.008l24.436-13.535 24.43 13.535a8.041 8.041 0 0 0 6.915.42l29.323-11.818 18.59 11.24a8.057 8.057 0 0 0 7.846.277l22.452-11.521 24.748 11.645a8.108 8.108 0 0 0 3.43.766h49.938c.045 0 .086-.012.133-.012 18.659 11.48 40.601 18.119 64.067 18.119 67.612 0 122.614-55.006 122.614-122.617 0-67.609-55.002-122.613-122.614-122.613-3.821 0-7.597.199-11.329.545v-38.092h92.396zm25.429-77.313v35.764c0 14.025-11.407 25.432-25.429 25.432h-.896c-.07-.004-.131-.027-.197-.029-13.609-.611-24.299-11.779-24.33-25.402v-35.764h50.852zm-66.967-79.953v115.742a41.497 41.497 0 0 0 8.723 25.406h-59.58V56.773c.029-13.25 9.989-24.146 23.157-25.342.189-.02.367-.078.554-.107h1.715c14.02 0 25.431 11.41 25.431 25.428zm66.967 317.426c0 58.725-47.771 106.498-106.495 106.498-58.721 0-106.499-47.773-106.499-106.498 0-58.721 47.778-106.496 106.499-106.496 58.723 0 106.495 47.775 106.495 106.496zm-229.11 0c0 34.707 14.514 66.063 37.768 88.391h-27.491l-26.704-12.561a8.03 8.03 0 0 0-7.104.123l-21.977 11.275-18.193-10.998a8.004 8.004 0 0 0-7.179-.578l-29.5 11.891-24.978-13.836a8.052 8.052 0 0 0-7.807 0l-23.176 12.836-11.454-10.848a8.065 8.065 0 0 0-9.373-1.232l-25.759 13.928h-10.71c5.475-7.035 8.752-15.859 8.777-25.428V55.766c0-13.477 10.965-24.441 24.44-24.441H364.45c-5.429 7.031-8.643 15.844-8.668 25.428V254.7c-54.433 12.505-95.164 61.308-95.164 119.478zm49.333-255.522a8.058 8.058 0 0 1-8.06 8.057H109.656a8.056 8.056 0 0 1-8.061-8.057 8.057 8.057 0 0 1 8.061-8.059h192.235a8.059 8.059 0 0 1 8.06 8.059zm0 51.317a8.061 8.061 0 0 1-8.06 8.059H109.656a8.06 8.06 0 0 1-8.061-8.059 8.06 8.06 0 0 1 8.061-8.061h192.235a8.06 8.06 0 0 1 8.06 8.061zm0 51.322a8.06 8.06 0 0 1-8.06 8.057H109.656a8.058 8.058 0 0 1-8.061-8.057 8.058 8.058 0 0 1 8.061-8.063h192.235a8.06 8.06 0 0 1 8.06 8.063zm-20.992 51.31a8.056 8.056 0 0 1-8.059 8.059H109.656c-4.454 0-8.061-3.605-8.061-8.059s3.606-8.059 8.061-8.059H280.9a8.057 8.057 0 0 1 8.059 8.059zm-35.417 51.317a8.055 8.055 0 0 1-8.057 8.057H109.656c-4.454 0-8.061-3.605-8.061-8.057s3.606-8.063 8.061-8.063h135.829c4.451 0 8.057 3.612 8.057 8.063zm-9.446 51.31a8.06 8.06 0 0 1-8.059 8.064H109.656a8.06 8.06 0 0 1-8.061-8.064c0-4.447 3.606-8.051 8.061-8.051h126.381c4.452.001 8.059 3.604 8.059 8.051zm79.017-1.054c0-4.449 3.606-8.061 8.056-8.061h44.005v-73.82a8.06 8.06 0 0 1 16.117 0v81.881a8.06 8.06 0 0 1-8.058 8.063H331.17a8.06 8.06 0 0 1-8.057-8.063z",fill:"#ffffff"})})}),xa=()=>t.jsx("svg",{xmlns:"http://www.w3.org/2000/svg",width:"48",height:"48",viewBox:"0 0 480 480",children:t.jsx("g",{children:t.jsx("path",{d:"M72 320c-35.785 0-72 10.992-72 32v96c0 21.008 36.215 32 72 32s72-10.992 72-32v-96c0-21.008-36.215-32-72-32zm0 16c36.375 0 56 11.36 56 16s-19.625 16-56 16-56-11.36-56-16 19.625-16 56-16zm0 128c-36.375 0-56-11.36-56-16v-11.2A126.879 126.879 0 0 0 72 448a126.879 126.879 0 0 0 56-11.2V448c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2A126.879 126.879 0 0 0 72 416a126.879 126.879 0 0 0 56-11.2V416c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2A126.879 126.879 0 0 0 72 384a126.879 126.879 0 0 0 56-11.2V384c0 4.64-19.625 16-56 16zM240 256c-35.785 0-72 10.992-72 32v160c0 21.008 36.215 32 72 32s72-10.992 72-32V288c0-21.008-36.215-32-72-32zm0 16c36.375 0 56 11.36 56 16s-19.625 16-56 16-56-11.36-56-16 19.625-16 56-16zm0 192c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V448c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V416c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V384c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V352c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V320c0 4.64-19.625 16-56 16zM408 160c-35.785 0-72 10.992-72 32v256c0 21.008 36.215 32 72 32s72-10.992 72-32V192c0-21.008-36.215-32-72-32zm0 16c36.375 0 56 11.36 56 16s-19.625 16-56 16-56-11.36-56-16 19.625-16 56-16zm0 288c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V448c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V416c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V384c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V352c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V320c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V288c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V256c0 4.64-19.625 16-56 16zm0-32c-36.375 0-56-11.36-56-16v-11.2a126.879 126.879 0 0 0 56 11.2 126.879 126.879 0 0 0 56-11.2V224c0 4.64-19.625 16-56 16zM392 0v16h60.688l-152 152H132.992L2.727 281.977l10.546 12.046L139.008 184h168.304L464 27.312V88h16V0zm0 0",fill:"#ffffff"})})}),Ca=()=>{const{t:e}=ne(),a=N(i=>i.customModal);return t.jsx(xt,{rootClassName:"tgg-payment-confirm-modal-root",className:"tgg-payment-confirm-modal",getContainer:()=>document.querySelector(".tgg-app-grid"),maskClosable:!0,centered:!0,closeIcon:null,width:350,open:a==null?void 0:a.visible,footer:null,children:t.jsxs("div",{className:"tgg-modal-content",children:[t.jsx("div",{className:"tgg-modal-info-icon",children:t.jsx(ua,{})}),t.jsxs("div",{className:"tgg-modal-body",children:[t.jsx("div",{className:"tgg-modal-info-text",children:(a==null?void 0:a.bodyText)??""}),t.jsxs("div",{className:"tgg-modal-buttons",children:[t.jsx("button",{className:"tgg-modal-confirm-btn",onClick:a==null?void 0:a.onOk,children:e("general.confirm")}),t.jsx("button",{className:"tgg-modal-cancel-btn",onClick:a==null?void 0:a.onCancel,children:e("general.cancel")})]})]})]})})},te=(e,a)=>{e=e.replace("#",""),e.length===3&&(e=e.split("").map(c=>c+c).join(""));const i=parseInt(e.substr(0,2),16),n=parseInt(e.substr(2,2),16),r=parseInt(e.substr(4,2),16);return`rgba(${i}, ${n}, ${r}, ${a})`},$e=(e,a)=>{if(typeof window>"u")return a;const i=e.startsWith("--")?e:`--${e}`;return getComputedStyle(document.documentElement).getPropertyValue(i).trim()||a},va=()=>$e("color-primary","#6366f1"),ka=()=>$e("color-secondary","#f59e0b"),lt=()=>$e("background-main","#1e293b"),Na=()=>$e("background-secondary","#0f172a"),xe=(e,a)=>{e=e.replace("#","");const i=parseInt(e,16),n=Math.min(255,Math.floor((i>>16)+(255-(i>>16))*a)),r=Math.min(255,Math.floor((i>>8&255)+(255-(i>>8&255))*a)),c=Math.min(255,Math.floor((i&255)+(255-(i&255))*a));return`#${(n<<16|r<<8|c).toString(16).padStart(6,"0")}`},we=(e,a)=>{e=e.replace("#","");const i=parseInt(e,16),n=Math.max(0,Math.floor((i>>16)*(1-a))),r=Math.max(0,Math.floor((i>>8&255)*(1-a))),c=Math.max(0,Math.floor((i&255)*(1-a)));return`#${(n<<16|r<<8|c).toString(16).padStart(6,"0")}`},be=()=>{const e=va();return{p50:xe(e,.95),p100:xe(e,.9),p200:xe(e,.8),p300:xe(e,.6),p400:xe(e,.4),p500:e,p600:we(e,.2),p700:we(e,.35),p800:we(e,.5),p900:we(e,.65),p950:we(e,.8)}},fe=()=>{const e=ka();return{s50:xe(e,.95),s100:xe(e,.9),s200:xe(e,.8),s300:xe(e,.6),s400:xe(e,.4),s500:xe(e,.2),s600:we(e,.1),s700:e,s800:we(e,.25),s900:we(e,.4),s950:we(e,.6)}},ae={get p50(){return be().p50},get p100(){return be().p100},get p200(){return be().p200},get p300(){return be().p300},get p400(){return be().p400},get p500(){return be().p500},get p600(){return be().p600},get p700(){return be().p700},get p800(){return be().p800},get p900(){return be().p900},get p950(){return be().p950},get s50(){return fe().s50},get s100(){return fe().s100},get s200(){return fe().s200},get s300(){return fe().s300},get s400(){return fe().s400},get s500(){return fe().s500},get s600(){return fe().s600},get s700(){return fe().s700},get s800(){return fe().s800},get s900(){return fe().s900},get s950(){return fe().s950},get background(){return lt()},get secondaryBackground(){return Na()},blue600:"#0e75cf",blue700:"#006dcc",gray900:"#1f2129",gray800:"#21232d"},w={main:{get border(){return te(ae.p500,.75)},get appBorder(){return te(ae.s900,.75)},get background(){return te(ae.background,1)},get primaryColor(){return te(ae.p500,1)},get secondaryColor(){return te(ae.s700,1)},get primaryTextColor(){return te(ae.p50,1)},get secondaryTextColor(){return te(ae.p500,1)},get secondaryBackground(){return te(ae.secondaryBackground,1)}},button:{get headerBg(){return te(ae.gray800,1)},get headerIconColor(){return te(ae.p500,1)},get buttonBorderColor(){return te(ae.p500,1)},get headerBorderHover(){return te(ae.p500,.5)},get headerIconLightColor(){return te(ae.p100,.5)},get primaryFilterBorderColor(){return te(ae.p500,.25)},get secondaryFilterBorderColor(){return te(ae.s700,.25)}}},Be={get borderPrimary(){return te(ae.p800,.5)},get textPrimary(){return te(ae.p200,.8)},get textSecondary(){return te(ae.p300,.5)},get background(){return lt()},get backgroundDim2(){return te("#18181b",.75)},get insetShadow(){return te(ae.p500,.15)}},wa=G.div.attrs({className:"tgg-create-invoice-container"})`
	position: absolute;

	height: 100%;
	width: 100%;

	z-index: -1;

	${({open:e})=>e==ge.Open||e==ge.Closing?"z-index: 10;":"z-index: -1;"}

	.tgg-create-invoice {
		height: 100%;
		width: 100%;

		backdrop-filter: blur(6px);

		background-color: rgba(0, 0, 0, 0.2);
		box-shadow: inset 0 0 200px 1px ${Be.insetShadow};

		transition:
			visibility 0s,
			opacity 0.25s linear;

		visibility: hidden;
		opacity: 0;

		overflow: hidden;
		border-radius: 25px;

		${({open:e})=>e==ge.Open&&`
			visibility: visible;
			opacity: 1;
		`}

		${({open:e})=>e==ge.Closing&&`
			visibility: visible;
			opacity: 0;
		`}
	}

	.tgg-create-invoice-body {
		display: flex;

		justify-content: center;

		gap: 2em;

		width: 100%;
		height: 100%;

		overflow: hidden;

		padding: 0 5em;

		.tgg-left-section,
		.tgg-middle-section,
		.tgg-right-section {
			display: flex;

			row-gap: 1em;

			padding: 2.5em 0;

			flex-direction: column;

			justify-content: start;

			width: 20%;
		}

		.tgg-middle-section {
			position: relative;

			width: fit-content;

			height: 100%;

			.tgg-create-invoice-container {
				display: flex;
				justify-content: center;
				align-items: center;

				position: relative;

				height: 100%;
				width: 100%;
			}
		}
	}
`,ja=()=>{const{t:e}=ne(),a=g.useRef(null),[i,n]=g.useState(0),r=N(u=>u.companyConfig),c=N(u=>u.playerData),k=N(u=>u.menuType),C=N(u=>u.jobInfo),[p,j]=g.useState({items:[],notes:"",recipientId:"",recipientName:"",sender:k==R.Personal?"__personal":(C==null?void 0:C.name)??"",senderId:(c==null?void 0:c.identifier)??"",senderName:(c==null?void 0:c.fullName)??"",taxPercentage:(r==null?void 0:r.taxPercentage)??0,total:0}),m=N(u=>u.filters),Z=N(u=>u.createInvoiceModalOpen),q=_(u=>u.setCustomModal);_(u=>u.setMenuType);const y=_(u=>u.setFilters),o=_(u=>u.setCreateInvoiceModalOpen),P=_(u=>u.setFlexOasisData);g.useEffect(()=>{Z==ge.Closing?setTimeout(()=>{o(ge.Closed)},250):Z==ge.Open&&j({items:[],notes:"",recipientId:"",recipientName:"",sender:k==R.Personal?"__personal":(C==null?void 0:C.name)??"",senderId:(c==null?void 0:c.identifier)??"",senderName:(c==null?void 0:c.fullName)??"",taxPercentage:(r==null?void 0:r.taxPercentage)??0,total:0})},[Z]),g.useLayoutEffect(()=>{var u;a.current&&n((u=a.current)==null?void 0:u.offsetHeight)},[]);const h=()=>{const u={...p};u.items=u.items.filter(M=>M.price!==-1),j(u),q(null)},d=()=>p.items.some(u=>u.price===-1),I=()=>{if(d()){q({visible:!0,onOk:()=>h(),onCancel:()=>q(null),bodyText:e("invoice.hasDirtyItems")});return}p.sender!=="__personal"&&(p.senderCompanyName=C==null?void 0:C.label),Y("billing:invoice:create",p,void 0,ze[69]).then(M=>{let f="";if(M!=null&&M.id){const z={...m,society:"byMe",status:v.Unpaid,orderBy:Ne.Newest,dateRange:{dateFrom:"",dateTo:""}};M.sender===K.Personal?y({...z,type:K.Personal}):y({...z,type:K.Society}),o(ge.Closing),f="invoiceCreated"}else f="invoiceCreateFailed";P({status:!0,message:f})})};return t.jsx(wa,{$middleSectionHeight:i,open:Z,children:t.jsx("div",{className:"tgg-create-invoice",children:t.jsxs("div",{className:"tgg-create-invoice-body",children:[t.jsx("div",{className:"tgg-left-section"}),t.jsx("div",{className:"tgg-middle-section",children:t.jsx("div",{className:"tgg-create-invoice-container",ref:a,children:t.jsx(Ze,{type:W.Create,body:t.jsx(ot,{invoiceDetails:p,setInvoiceDetails:j}),footer:t.jsx(st,{handleCancelInvoice:()=>o(ge.Closing),invoiceDetails:p,handleCreateInvoice:I})})})}),t.jsx("div",{className:"tgg-right-section"})]})})})},Ia=G.div.attrs({className:"tgg-statistics-container"})`
	position: absolute;

	height: 100%;
	width: 100%;

	${({$open:e})=>e==Ce.Open||e==Ce.Closing?"z-index: 10;":"z-index: -1;"}

	.tgg-statistics {
		position: relative;

		height: 100%;
		width: 100%;

		backdrop-filter: blur(10px);

		background-color: rgb(15, 19, 39, 0.75);
		/* background-color: white; */
		box-shadow: inset 0 0 200px 1px var(--color-primary-25);

		transition:
			visibility 0s,
			opacity 0.25s linear;

		visibility: hidden;
		opacity: 0;

		overflow: hidden;
		border-radius: 25px;

		${({$open:e})=>e==Ce.Open&&`
			visibility: visible;
			opacity: 1;
		`}

		${({$open:e})=>e==Ce.Closing&&`
			visibility: visible;
			opacity: 0;
		`}

        .tgg-close-btn {
			position: absolute;

			top: 0.5em;
			right: 1em;

			background-color: transparent;
			border: none;

			font-size: 1.5em;

			width: 1em;
			height: 1em;

			svg {
				transition: opacity 0.25s ease-in-out;

				color: var(--color-primary);
				fill: var(--color-primary);

				width: 100%;
				height: 100%;
			}

			&:hover {
				cursor: pointer;

				svg {
					opacity: 0.75;
				}
			}
		}

		.tgg-statistics-grid {
			display: flex;
			flex-direction: column;

			gap: 3em;

			padding: 4.5em 7.5em 2em 7.5em;

			.tgg-header-row {
				display: flex;
				align-items: center;

				.tgg-switch-btn-col {
					display: flex;
					justify-content: flex-end;
				}

				.tgg-title {
					font-size: 1.5em;
					font-weight: 600;
					color: ${w.main.primaryTextColor};
					opacity: 0.75;
				}

			.tgg-switch-society-btn {
				background-color: ${w.main.secondaryBackground};
				border: none;

				font-size: 1em;
				font-weight: 600;
				color: ${w.main.primaryTextColor};

				padding: 0.75em 1em;
				border-radius: 10px;

				transition: color 0.25s ease-in-out;

				box-shadow: 0 0 1.5px 0.5px var(--color-primary);

				&:hover {
					cursor: pointer;
					color: var(--color-primary);
				}
			}
			}
		}
	}

	.tgg-chart-container {
		position: relative;

		background-color: rgba(77, 77, 77, 0.05);
		backdrop-filter: blur(15px);

		border-radius: 17.5px;

		padding: 2em 1.5em;

		overflow: hidden;

		border-left: 1px solid rgba(80, 80, 80, 0.35);
		border-right: 1px solid rgba(80, 80, 80, 0.35);

		box-shadow: 0 0 2.5px 0.5px ${Be.insetShadow};

		height: 370px;

		.tgg-chart-title {
			font-size: 1.25em;
			font-weight: 600;
			color: ${w.main.primaryTextColor};
			opacity: 0.75;
		}

		.tgg-addon-top,
		.tgg-addon-bottom {
			position: absolute;

			left: 50%;
			right: 50%;
			transform: translateX(-50%);

			width: 70%;
			height: 1px;

			background: linear-gradient(
				90deg,
				rgba(255, 255, 255, 0) 0%,
				var(--color-primary),
				rgba(255, 255, 255, 0) 100%
			);
		}

		.tgg-addon-top {
			top: 0;
		}

		.tgg-addon-bottom {
			bottom: 0;
		}
	}

	.tgg-recent-payments {
		position: relative;

		background-color: rgba(77, 77, 77, 0.05);
		backdrop-filter: blur(15px);

		border-radius: 17.5px;

		padding: 2em 1.5em;

		overflow: hidden;

		border-left: 1px solid rgba(80, 80, 80, 0.35);
		border-right: 1px solid rgba(80, 80, 80, 0.35);

		box-shadow: 0 0 2.5px 0.5px ${Be.insetShadow};

		height: 370px;

		.tgg-addon-top,
		.tgg-addon-bottom {
			position: absolute;

			left: 50%;
			right: 50%;
			transform: translateX(-50%);

			width: 70%;
			height: 1px;

			background: linear-gradient(
				90deg,
				rgba(255, 255, 255, 0) 0%,
				var(--color-primary),
				rgba(255, 255, 255, 0) 100%
			);
		}

		.tgg-addon-top {
			top: 0;
		}

		.tgg-addon-bottom {
			bottom: 0;
		}

		.tgg-title {
			font-size: 1.25em;
			font-weight: 600;
			color: ${w.main.primaryTextColor};
			opacity: 0.75;
		}

		.tgg-payments-container {
			display: flex;
			flex-direction: column;
			gap: 0.5em;

			overflow-y: auto;
			overflow-x: hidden;

			margin-top: 0.25em;

			height: 300px;

			.tgg-no-recent-pay {
				display: flex;
				justify-content: center;
				align-items: center;

				font-size: 1.15em;
				font-weight: 600;
				color: ${w.main.primaryTextColor};

				opacity: 0.5;

				height: 100%;
				width: 100%;
			}

			&::-webkit-scrollbar {
				width: 3px;
				height: 3px;

				background-clip: padding-box;
				padding: 1em 0;
			}

			&::-webkit-scrollbar-button {
				width: 0px;
				height: 0px;
			}

			&::-webkit-scrollbar-thumb {
				background: var(--color-primary);
				border: 0px none var(--color-primary);
				border-radius: 50px;
				opacity: 0.7;
			}

			&::-webkit-scrollbar-thumb:hover {
				background: var(--color-primary);
				opacity: 0.9;
			}

			&::-webkit-scrollbar-thumb:active {
				background: var(--color-primary);
				opacity: 0.7;
			}

			&::-webkit-scrollbar-track {
				background: var(--color-primary);
				border: 0px none var(--color-primary);

				border-radius: 50px;
			}

			&::-webkit-scrollbar-track:hover {
				background: ${w.main.primaryColor};
			}

			&::-webkit-scrollbar-track:active {
				background: ${w.main.primaryColor};
			}

			&::-webkit-scrollbar-corner {
				background: transparent;
			}

			.tgg-payment {
				display: flex;
				justify-content: space-between;

				padding: 0.5em 0;

				padding-right: 1em;

				.tgg-payment-header {
					display: flex;
					flex-direction: column;

					gap: 0.25em;

					.tgg-payment-title {
						font-size: 1em;
						font-weight: 600;
						color: ${w.main.primaryTextColor};
					}

				.tgg-payment-date {
					font-size: 0.85em;
					font-weight: 600;
					color: var(--color-primary);
					opacity: 0.75;
				}
				}

				.tgg-payment-amount {
					display: flex;
					align-items: center;

					font-size: 1em;
					font-weight: 600;
					color: ${w.main.primaryTextColor};
				}

			.tgg-view-btn {
				background-color: transparent;
				border: none;

				font-size: 1em;
				font-weight: 600;
				color: var(--color-primary);

				padding: 0.5em 1em;
				border-radius: 10px;

				will-change: color, box-shadow;
				transition: color 0.15s ease-out, box-shadow 0.15s ease-out;

				&:hover {
					cursor: pointer;
					color: #fff;
					box-shadow: 0 0 2.5px 0 var(--color-primary);
				}
			}
			}
		}
	}

	.tgg-info-header-row {
		display: flex;
		justify-content: space-between;

		row-gap: 1em;

		.tgg-info-card {
			position: relative;

			display: flex;
			align-items: center;

			width: 100%;
			height: 120px;

			background-color: rgba(77, 77, 77, 0.05);
			backdrop-filter: blur(15px);

			border-radius: 17.5px;

			padding: 2em 1.5em;

			border-left: 1px solid var(--color-primary-15);
			border-right: 1px solid var(--color-primary-15);

			box-shadow: 0 0 2.5px 0.5px var(--color-primary-25);

			.tgg-addon-top,
			.tgg-addon-bottom {
				position: absolute;

				left: 50%;
				right: 50%;
				transform: translateX(-50%);

				width: 70%;
				height: 1px;

				background: linear-gradient(
					90deg,
					rgba(255, 255, 255, 0) 0%,
					var(--color-primary),
					rgba(255, 255, 255, 0) 100%
				);
			}

			.tgg-addon-top {
				top: 0;
			}

			.tgg-addon-bottom {
				bottom: 0;
			}

			.tgg-card-content {
				display: flex;

				width: 100%;

				gap: 2em;

				justify-content: start;

				.tgg-count {
					svg {
						font-size: 2em;
					}
				}

				.tgg-content {
					display: flex;
					flex-direction: column;

					gap: 0.25em;

					.tgg-value {
						font-size: 2em;
						font-weight: 600;
						color: ${w.main.primaryTextColor};
					}

				.tgg-label {
					font-size: 1em;
					font-weight: 600;
					color: var(--color-primary);
					opacity: 0.65;
				}

					&.tgg-stats-content {
						flex-direction: row;

						justify-content: space-between;
						align-items: center;
						width: 100%;
					}
				}
			}
		}
	}

	.tgg-filters {
		display: flex;

		gap: 0.05em;

		.tgg-filter-btn {
			display: flex;
			justify-content: center;
			align-items: center;

			height: 2.15em;

			border-radius: 5px;

			overflow: hidden;

			padding: 0 1em;

			font-size: 1em;
			font-weight: 600;

			color: ${w.main.primaryTextColor};

			transition: color 0.25s ease-in-out;

			&:hover {
				cursor: pointer;
				color: var(--color-primary);
			}

			&.tgg-active {
				background-color: var(--color-primary);
				font-weight: 700;

				&:hover {
					box-shadow: 0 0 5px 0 var(--color-primary);
					color: #fff;
				}
			}
		}
	}

	.tgg-filters-wrapper {
		position: relative;

		.tgg-dropdown-filters {
			display: flex;
			justify-content: center;
			align-items: center;

			height: 30px;
			aspect-ratio: 1/1;

			background-color: transparent;
			border: none;
			outline: none;

			font-size: 1em;
			font-weight: 600;

			color: ${w.main.primaryTextColor};

			border-radius: 10px;

			box-shadow: 0 0 1.5px 0.5px var(--color-primary);

			opacity: 0.5;

			svg {
				font-size: 1.25em;
			}

			transition: all 0.25s ease-in-out;
			&:hover {
				opacity: 0.75;
				cursor: pointer;
				color: var(--color-primary);
			}

			&.tgg-filters-open {
				opacity: 1;
				border-bottom-left-radius: 0;
				border-bottom-right-radius: 0;
			}
		}

		.tgg-type-filters {
			position: absolute;

			z-index: 1;

			top: 30px;
			right: 0;

			display: flex;
			flex-direction: column;

			padding: 0.5em 1em;

			height: 0;
			width: 100px;

			opacity: 0;

			transition: all 0.25s ease-in-out;

			background-color: ${w.main.secondaryBackground};

			border-top-left-radius: 10px;
			border-bottom-right-radius: 10px;
			border-bottom-right-radius: 10px;

			box-shadow: 0 0 2.5px 0 var(--color-primary);

			&.tgg-open {
				height: 115px;
				opacity: 1;
			}

			.tgg-filter {
				display: flex;
				justify-content: start;
				align-items: center;

				height: 2em;

				font-size: 0.95em;
				font-weight: 600;

				color: ${w.main.primaryTextColor};

				transition: color 0.25s ease-in-out;

				&:hover {
					cursor: pointer;
					color: var(--color-primary);
				}

				&.tgg-active {
					color: var(--color-primary);
					font-weight: 700;

					&:hover {
						opacity: 0.75;
					}
				}
			}
		}
	}
`,Pa=()=>{const{t:e}=ne(),[a,i]=g.useState(0),[n,r]=g.useState(0),[c,k]=g.useState(0),[C,p]=g.useState([]),[j,m]=g.useState([]),[Z,q]=g.useState("__personal"),[y,o]=g.useState({sender:"",period:"month",status:v.All}),[P,h]=g.useState(!0),[d,I]=g.useState(!1),u=N(s=>s.statisticsOpen),M=N(s=>s.settingsConfig),f=N(s=>s.companyConfig),z=N(s=>s.playerData),$=N(s=>s.jobInfo),ce=M.currencyFormat,x=M.dateTimeFormat,A=$==null?void 0:$.label,E=_(s=>s.setViewInvoice),D=_(s=>s.setViewInvoiceModalOpen),ie=_(s=>s.setStatisticsOpen);g.useEffect(()=>{if(u===Ce.Closing)setTimeout(()=>{ie(Ce.Closed)},250);else if(u===Ce.Open){const s={sender:"",period:"month",status:v.All};ue()?s.sender=(f==null?void 0:f.jobIdentifier)??"__personal":(s.sender="__personal",s.senderId=(z==null?void 0:z.identifier)??""),q(s.sender),o(s),H(s)}},[u]);const V=s=>{Y("billing:invoice:refresh-statistics",s??y,void 0,Ke).then(S=>{S&&(i(S.totalInvoices),r(S.totalIncome),k(S.totalExpectedIncome))})},H=s=>{h(!0),Y("billing:invoice:statistics",s??y,void 0,Ke).then(S=>{S&&(i(S.totalInvoices),r(S.totalIncome),k(S.totalExpectedIncome),p([...S.graphData].reverse()),m(S.recentPayments)),h(!1)})},X=()=>{ie(Ce.Closing)},T=s=>oe(pe(+s),ce),ve=()=>{const s=f==null?void 0:f.create;return!!(s!=null&&s.includes("__personal"))},ue=()=>{const s=f==null?void 0:f.create,S=$==null?void 0:$.grade.level;return!!(s!=null&&s.includes("-1")||S&&(s!=null&&s.includes(S)))},je=()=>{const s={sender:"",period:"month",status:v.All};Z==="__personal"?(q((f==null?void 0:f.jobIdentifier)??"__personal"),s.sender=(f==null?void 0:f.jobIdentifier)??"__personal"):(q("__personal"),s.sender="__personal",s.senderId=(z==null?void 0:z.identifier)??""),o(s),H(s)},he=s=>{Y("billing:invoice:count",s,void 0,0).then(S=>{i(S)})},b=s=>{const S={...y,period:s};o(S),V(S)},F=s=>{const S={...y,status:s};o(S),he(S),I(!1)},le=s=>{E(s),D(re.Open)};return t.jsx(Ia,{$open:u,children:t.jsxs("div",{className:"tgg-statistics",children:[t.jsx("button",{className:"tgg-close-btn",onClick:X,children:t.jsx(at,{})}),t.jsxs("div",{className:"tgg-statistics-grid",children:[t.jsxs(Ae,{className:"tgg-header-row",children:[t.jsx(se,{span:12,children:Z==="__personal"?t.jsx("div",{className:"tgg-title",children:e("statistics.personalTitle")}):t.jsxs("div",{className:"tgg-title",children:[A," ",e("statistics.statisticsLabel")]})}),t.jsx(se,{span:12,className:"tgg-switch-btn-col",children:ue()&&ve()&&t.jsxs("button",{className:"tgg-switch-society-btn",onClick:je,children:[e("statistics.switchTo"),Z==="__personal"?A:e("statistics.personalLabel")]})})]}),t.jsxs(Ae,{className:"tgg-info-header-row",gutter:25,style:{zIndex:2},children:[t.jsx(se,{span:24,children:t.jsxs("div",{className:"tgg-filters",children:[t.jsx("div",{onClick:()=>b("today"),className:`tgg-filter-btn ${(y==null?void 0:y.period)==="today"?" tgg-active":""}`,children:e("statistics.today")}),t.jsx("div",{onClick:()=>b("last_week"),className:`tgg-filter-btn ${(y==null?void 0:y.period)==="last_week"?" tgg-active":""}`,children:e("statistics.lastWeek")}),t.jsx("div",{onClick:()=>b("month"),className:`tgg-filter-btn ${(y==null?void 0:y.period)==="month"?" tgg-active":""}`,children:e("statistics.lastMonth")}),t.jsx("div",{onClick:()=>b("year"),className:`tgg-filter-btn ${(y==null?void 0:y.period)==="year"?" tgg-active":""}`,children:e("statistics.lastYear")})]})}),t.jsx(se,{span:8,children:t.jsxs("div",{className:"tgg-info-card",children:[t.jsx("div",{className:"tgg-addon-top"}),t.jsx("div",{className:"tgg-addon-bottom"}),t.jsxs("div",{className:"tgg-card-content",children:[t.jsx("div",{className:"tgg-icon tgg-count",children:t.jsx(ba,{})}),t.jsxs("div",{className:"tgg-content tgg-stats-content",children:[t.jsxs("div",{className:"tgg-stats",children:[t.jsx("div",{className:"tgg-value",children:a}),t.jsxs("div",{className:"tgg-label",children:[y.status===v.All&&e("statistics.totalInvoices"),y.status===v.Paid&&e("statistics.totalPaid"),y.status===v.Unpaid&&e("statistics.totalUnpaid"),y.status===v.Cancelled&&e("statistics.totalCancelled")]})]}),t.jsxs("div",{className:"tgg-filters-wrapper",children:[t.jsx("button",{className:`tgg-dropdown-filters ${d?" tgg-filters-open":""}`,onClick:()=>I(!d),children:t.jsx(it,{})}),d&&t.jsxs("div",{className:`tgg-type-filters ${d?" tgg-open":""}`,children:[t.jsx("div",{onClick:()=>F(v.All),className:`tgg-filter ${y.status===v.All?" tgg-active":""}`,children:e("statistics.all")}),t.jsx("div",{onClick:()=>F(v.Paid),className:`tgg-filter ${y.status===v.Paid?" tgg-active":""}`,children:e("statistics.paid")}),t.jsx("div",{onClick:()=>F(v.Unpaid),className:`tgg-filter ${y.status===v.Unpaid?" tgg-active":""}`,children:e("statistics.unpaid")}),t.jsx("div",{onClick:()=>F(v.Cancelled),className:`tgg-filter ${y.status===v.Cancelled?" tgg-active":""}`,children:e("statistics.cancelled")})]})]})]})]})]})}),t.jsx(se,{span:8,children:t.jsxs("div",{className:"tgg-info-card",children:[t.jsx("div",{className:"tgg-addon-top"}),t.jsx("div",{className:"tgg-addon-bottom"}),t.jsxs("div",{className:"tgg-card-content",children:[t.jsx("div",{className:"tgg-icon",children:t.jsx(xa,{})}),t.jsxs("div",{className:"tgg-content",children:[t.jsx("div",{className:"tgg-value",children:oe(pe(n),ce)}),t.jsx("div",{className:"tgg-label",children:e("statistics.totalIncome")})]})]})]})}),t.jsx(se,{span:8,children:t.jsxs("div",{className:"tgg-info-card",children:[t.jsx("div",{className:"tgg-addon-top"}),t.jsx("div",{className:"tgg-addon-bottom"}),t.jsxs("div",{className:"tgg-card-content",children:[t.jsx("div",{className:"tgg-icon",children:t.jsx(fa,{})}),t.jsxs("div",{className:"tgg-content",children:[t.jsx("div",{className:"tgg-value",children:oe(pe(c),ce)}),t.jsx("div",{className:"tgg-label",children:e("statistics.totalUnpaidExp")})]})]})]})})]}),t.jsxs(Ae,{justify:"space-between",gutter:25,style:{zIndex:1},children:[t.jsx(se,{span:16,children:t.jsxs("div",{className:"tgg-chart-container",children:[t.jsx("div",{className:"tgg-chart-title",children:e("statistics.incomeOverview")}),t.jsx("div",{className:"tgg-addon-top"}),t.jsx("div",{className:"tgg-addon-bottom"}),t.jsxs(Ct,{width:P?0:800,height:300,data:C,margin:{top:50,right:30,left:25,bottom:50},children:[t.jsx("defs",{children:t.jsxs("linearGradient",{id:"colorPv",x1:"0",y1:"0",x2:"0",y2:"1",children:[t.jsx("stop",{offset:"5%",stopColor:w.main.primaryColor,stopOpacity:.8}),t.jsx("stop",{offset:"95%",stopColor:w.main.primaryColor,stopOpacity:0})]})}),t.jsx(vt,{dataKey:"date",angle:-50,textAnchor:"end",fontSize:12,stroke:"rgba(255, 255, 255, 0.75)"}),t.jsx(kt,{tickFormatter:T,fontSize:12,stroke:"rgba(255, 255, 255, 0.75)"}),t.jsx(Nt,{vertical:!1,stroke:"rgba(255, 255, 255, 0.15)"}),t.jsx(wt,{dot:{fill:"#fff",stroke:w.main.primaryColor,strokeWidth:2},height:300,type:"monotone",dataKey:"total",stroke:w.main.primaryColor,fillOpacity:1,fill:"url(#colorPv)"}),t.jsx(jt,{animationDuration:0,formatter:s=>[oe(pe(+s),ce),e("statistics.income")]})]})]})}),t.jsx(se,{span:8,children:t.jsxs("div",{className:"tgg-recent-payments",children:[t.jsx("div",{className:"tgg-addon-top"}),t.jsx("div",{className:"tgg-addon-bottom"}),t.jsx("div",{className:"tgg-title",children:e("statistics.recentPayments")}),t.jsxs("div",{className:"tgg-payments-container",children:[j.length===0&&t.jsx("div",{className:"tgg-no-recent-pay",children:e("statistics.emptyRecentPayments")}),j.map((s,S)=>t.jsxs("div",{className:"tgg-payment",children:[t.jsxs("div",{className:"tgg-payment-header",children:[t.jsx("div",{className:"tgg-payment-title",children:s.recipientName}),t.jsx("div",{className:"tgg-payment-date",children:rt(s.lastModified??0,x)})]}),t.jsx("div",{className:"tgg-payment-amount",children:oe(pe(s.total+s.total*(s.taxPercentage/100)),ce)}),t.jsx("button",{className:"tgg-view-btn",onClick:()=>le(s),children:e("statistics.view")})]},S))]})]})})]})]})]})})},Sa=G.div.attrs({className:"tgg-view-invoice-container"})`
	position: absolute;

	height: 100%;
	width: 100%;

	${({$open:e})=>e==re.Open||e==re.Closing?"z-index: 10;":"z-index: -1;"}

	.tgg-view-invoice {
		height: 100%;
		width: 100%;

		backdrop-filter: blur(6px);

		background-color: rgba(0, 0, 0, 0.2);
		box-shadow: inset 0 0 200px 1px ${Be.insetShadow};

		transition:
			visibility 0s,
			opacity 0.25s linear;

		visibility: hidden;
		opacity: 0;

		overflow: hidden;
		border-radius: 25px;

		${({$open:e})=>e==re.Open&&`
			visibility: visible;
			opacity: 1;
		`}

		${({$open:e})=>e==re.Closing&&`
			visibility: visible;
			opacity: 0;
		`}
	}

	.tgg-create-invoice-body {
		display: flex;

		justify-content: center;

		gap: 2em;

		width: 100%;
		height: 100%;

		overflow: hidden;

		.tgg-left-section,
		.tgg-middle-section,
		.tgg-right-section {
			display: flex;

			row-gap: 1em;

			padding: 2.5em 0;

			flex-direction: column;

			justify-content: start;

			width: -webkit-fill-available;
		}

		.tgg-middle-section {
			position: relative;

			width: fit-content;

			height: 100%;

			${({$open:e})=>e==re.Open&&`
				.tgg-view-invoice-container {
					display: flex;
					justify-content: center;
					align-items: center;

					position: relative;

					height: 100%;
					width: 100%;
				}
			`}
		}

		.tgg-right-section {
			display: flex;

			align-items: end;

			.tgg-close-btn {
				background-color: transparent;
				border: none;

				font-size: 1.5em;

				width: 1em;
				height: 1em;

				margin-right: 2.25em;

				svg {
					transition: opacity 0.25s ease-in-out;

					color: var(--color-primary);
					fill: var(--color-primary);

					width: 100%;
					height: 100%;
				}

				&:hover {
					cursor: pointer;

					svg {
						opacity: 0.75;
					}
				}
			}
		}
	}
`,La=()=>{const e=g.useRef(null),[a,i]=g.useState(0),n=N(p=>p.viewInvoice),r=N(p=>p.viewInvoiceModalOpen),c=_(p=>p.setViewInvoiceModalOpen),k=_(p=>p.setViewInvoice);g.useEffect(()=>{r===re.Closing&&setTimeout(()=>{c(re.Closed)},250)},[r]),g.useLayoutEffect(()=>{var p;e.current&&i((p=e.current)==null?void 0:p.offsetHeight)},[]);const C=()=>{c(re.Closing),k(null)};return t.jsx(Sa,{$middleSectionHeight:a,$open:r,children:t.jsx("div",{className:"tgg-view-invoice",children:t.jsxs("div",{className:"tgg-create-invoice-body",children:[t.jsx("div",{className:"tgg-left-section"}),t.jsx("div",{className:"tgg-middle-section",children:t.jsx("div",{className:"tgg-view-invoice-container",ref:e,children:n&&t.jsx(Ze,{type:W.Details,body:t.jsx(Ye,{invoice:n,invoiceLocation:W.Details}),footer:t.jsx(Ue,{invoice:n,invoiceLocation:W.Details})})})}),t.jsx("div",{className:"tgg-right-section",children:t.jsx("button",{className:"tgg-close-btn",onClick:C,children:t.jsx(at,{})})})]})})})},qa=G.div.attrs({className:"tgg-settings-drawer-container"})`
	.tgg-settings-drawer {
		border-right: 0.3em solid black;
		border-top: 0.3em solid black;
		border-bottom: 0.3em solid black;
		border-top-right-radius: 30px;
		border-bottom-right-radius: 30px;
		background-color: var(--background-secondary);

		.ant-drawer-header {
			border-color: ${w.main.primaryColor};

			.ant-drawer-title {
				color: #fff;
			}

			.ant-drawer-close {
				color: #fff;
			}
		}
	}

	.tgg-scaling-slider-container {
		display: flex;
		align-items: center;

		gap: 1em;

		svg {
			font-size: 1.75em;
			color: ${w.main.primaryColor};
		}

		.ant-slider {
			width: 100%;

			.ant-slider-rail {
				background-color: ${w.main.primaryColor};
			}
		}
	}

	.tgg-label {
		color: #fff;
		font-size: 1.25em;
		font-weight: 600;
		margin-bottom: 0.25em;
	}
`,Aa=()=>{const{t:e}=ne(),a=N(m=>m.settingsDrawerOpen),i=N(m=>m.playerData),n=N(m=>m.resizeBy),r=i==null?void 0:i.identifier,c=_(m=>m.setResizeBy),k=_(m=>m.setSettingsDrawerOpen);g.useEffect(()=>{C()},[r]);const C=()=>{if(!r)return;const m=localStorage.getItem("billing-settings");let Z=m?JSON.parse(m):{};Z[r]||(Z[r]={resizeBy:1},localStorage.setItem("billing-settings",JSON.stringify(Z))),c(Z[r].resizeBy)},p=m=>{if(!r)return;const Z=localStorage.getItem("billing-settings");let q=Z?JSON.parse(Z):{};q[r]||(q[r]={}),q[r].resizeBy=m,localStorage.setItem("billing-settings",JSON.stringify(q))},j=m=>{isNaN(m)||(c(m),p(m))};return t.jsx(qa,{children:t.jsxs(It,{title:"Settings",onClose:()=>k(!1),open:a,getContainer:()=>document.querySelector(".tgg-settings-drawer-container"),className:"tgg-settings-drawer",children:[t.jsx("div",{className:"tgg-label",children:e("general.scale")}),t.jsxs("div",{className:"tgg-scaling-slider-container",children:[t.jsx(Pt,{}),t.jsx(St,{onChange:j,step:.1,min:.9,max:1.3,value:typeof n=="number"?n:1})]})]})})},{RangePicker:_a}=Lt,Ba=G.div.attrs({className:"tgg-custom-range-picker-wrapper"})`
	.tgg-range-picker-input-wrapper {
		position: relative;

		width: 95%;
		height: 45px;

		overflow: hidden;

		z-index: 1;

		border-top-right-radius: 17.5px;
		border-bottom-right-radius: 17.5px;

		transition: border-radius 0.25s ease-in-out;
		${({$rangePickerOpen:e})=>e&&"border-top-right-radius: 0;"}

		box-shadow: 1.5px 0px 2.5px 1.5px
				${w.button.primaryFilterBorderColor};

		.tgg-custom-range-picker {
			width: 100%;
			height: 100%;

			background-color: var(--background-secondary);

			border-top-right-radius: 17.5px;
			border-bottom-right-radius: 17.5px;

			transition: border-radius 0.25s ease-in-out;
			${({$rangePickerOpen:e})=>e&&"border-top-right-radius: 0;"}

			border-top-left-radius: 0;
			border-bottom-left-radius: 0;

			border-left: none;
			border: none;

			overflow: hidden;

			.ant-picker-input:first-child {
				input {					
					font-family: 'Poppins', sans-serif;

					text-align: center;
					color: var(--color-primary);
				}
			}

			.ant-picker-range-separator {
				height: 100%;

				.ant-picker-separator {
					display: flex;
					align-items: center;
					height: 100%;
				}

				svg {
					color: var(--color-secondary);
					font-size: 1.25em;
				}
			}

			.ant-picker-input {
				input {
					&::placeholder {
						font-size: 1.1em;
						color: var(--color-primary);
						font-family: 'Poppins', sans-serif;
					}

					font-size: 1em;
					font-family: 'Poppins', sans-serif;
					text-align: center;
					color: var(--color-primary) !important;

					&:hover {
						cursor: pointer;
					}
				}
			}

			.anticon-calendar {
				visibility: hidden;
			}

			.ant-picker-suffix,
			.ant-picker-clear {
				z-index: 2;

				svg {
					color: var(--color-primary);
				}
			}
		}

		.tgg-attachment {
			position: absolute;
			right: -2px;
			top: 50%;
			bottom: 50%;
			transform: translateY(-50%);

			height: 50%;
			width: 5px;

			background-color: var(--color-primary);
			filter: drop-shadow(-1px 0px 5px var(--color-primary));
		}

		.tgg-side-border {
			position: absolute;

			top: 0;

			height: 100%;
			width: 18px;

			transition: border-radius 0.25s ease-in-out;

			border-radius: 0 17.5px 17.5px 0;

			${({$rangePickerOpen:e})=>e&&"border-top-right-radius: 0;"}

			right: 0;

			border-top: 1px solid var(--color-primary);
			border-right: 1px solid var(--color-primary);
			border-bottom: 1px solid var(--color-primary);

			overflow: hidden;

			z-index: 0;
		}

		.tgg-border-top,
		.tgg-border-bottom {
			position: absolute;

			left: 0;

			height: 1px;
			width: 100%;

			background: linear-gradient(
				90deg,
				var(--color-primary) 0%,
				rgba(22, 26, 32, 0) 90%
			);

			background: linear-gradient(
				90deg,
				rgba(22, 26, 32, 0) 0%,
				var(--color-primary) 90%
			);

			z-index: 1;
		}

		.tgg-border-top {
			top: 0;
		}

		.tgg-border-bottom {
			bottom: 0;
		}
	}

	/* Range Picker Popup */
	.tgg-picker-dropdown-wrapper {
		position: absolute;

		z-index: 10;

		.ant-picker-ok button {
			background-color: var(--color-primary);
			color: ${w.main.primaryTextColor};
			border-radius: 7.5px;
			border: none;
			outline: none;

			&:hover:not(:disabled) {
				box-shadow: 0px 0px 2.5px 0.5px var(--color-primary);
			}
		}

		.ant-picker-dropdown {
			top: -407.5px !important;
			left: 0px !important;

			.ant-picker-range-arrow {
				display: none;

				&:before,
				&:after {
					background: var(--background-secondary) !important;
					box-shadow: 0px 0px 2.5px 0.5px var(--color-primary) !important;
				}
			}

			.ant-picker-panel-container {
				background-color: var(--background-secondary);
				box-shadow: 0px 0px 2.5px 0.5px var(--color-primary);

				border-top-left-radius: 0;
				border-bottom-left-radius: 0;

				border-top-right-radius: 17.5px;
				border-bottom-right-radius: 17.5px;

				.ant-picker-header {
					border-color: var(--color-primary);

					.ant-picker-header-view {
						color: ${w.main.primaryTextColor};
					}

					.ant-picker-header-super-prev-btn {
						.ant-picker-super-prev-icon:before,
						.ant-picker-super-prev-icon:after {
							color: var(--color-primary);
						}

						&:hover {
							.ant-picker-super-prev-icon:before,
							.ant-picker-super-prev-icon:after {
								color: var(--color-secondary);
							}
						}
					}

					.ant-picker-header-prev-btn {
						.ant-picker-prev-icon:before {
							color: var(--color-primary);
						}

						&:hover {
							.ant-picker-prev-icon:before {
								color: var(--color-secondary);
							}
						}
					}

					.ant-picker-header-super-next-btn {
						.ant-picker-super-next-icon:before,
						.ant-picker-super-next-icon:after {
							color: var(--color-primary);
						}

						&:hover {
							.ant-picker-super-next-icon:before,
							.ant-picker-super-next-icon:after {
								color: var(--color-secondary);
							}
						}
					}

					.ant-picker-header-next-btn {
						.ant-picker-next-icon:before {
							color: var(--color-primary);
						}
						&:hover {
							.ant-picker-next-icon:before {
								color: var(--color-secondary);
							}
						}
					}
				}

				thead tr th {
					color: var(--color-primary);
				}

				.ant-picker-cell-inner {
					color: ${w.main.primaryTextColor};
				}

				.ant-picker-cell {
					&:hover:not(.ant-picker-cell-disabled) .ant-picker-cell-inner {
						background: var(--color-primary) !important;
						color: #fff !important;
					}

					&.ant-picker-cell-selected .ant-picker-cell-inner {
						background: var(--color-primary) !important;
						color: #fff !important;
						border-color: var(--color-primary) !important;
					}

					&.ant-picker-cell-today .ant-picker-cell-inner {
						border-color: var(--color-primary) !important;
						border: 1px solid var(--color-primary) !important;
					}

					&.ant-picker-cell-today:not(.ant-picker-cell-selected) .ant-picker-cell-inner {
						border-color: var(--color-primary) !important;
						border: 1px solid var(--color-primary) !important;
					}

					&.ant-picker-cell-today:not(.ant-picker-cell-selected):not(.ant-picker-cell-in-range) .ant-picker-cell-inner {
						border-color: var(--color-primary) !important;
						border: 1px solid var(--color-primary) !important;
					}
				}
			}
		}
	}

	.ant-picker-cell-range-start,
	.ant-picker-cell-range-end {
		&:before {
			border-top: 1px solid var(--color-primary);
			border-bottom: 1px solid var(--color-primary);
			background: var(--color-primary);
			opacity: 0.3;
		}
	}

	.ant-picker-cell-in-range {
		.ant-picker-cell-inner {
			background: transparent;
		}

		&:before {
			border-top: 1px solid var(--color-primary);
			border-bottom: 1px solid var(--color-primary);
			background: var(--color-primary);
			opacity: 0.3;
		}
	}

	.ant-picker-presets {
		ul {
			/* font-size: 1.1em; */
			font-weight: 600;
			border-color: ${w.main.border} !important;

			li {
				position: relative;
				color: ${w.main.primaryTextColor};

				&:hover {
					color: ${w.main.secondaryTextColor};
				}

				&:before {
					content: '';
					position: absolute;

					left: 0;

					top: 50%;
					bottom: 50%;
					transform: translateY(-50%);

					width: 2px;
					height: 60%;

					background-color: var(--color-primary);
					box-shadow: 0px 0px 2.5px 0.5px var(--color-primary);
				}
			}
		}
	}
	/* Range Picker Popup */
`,Za=()=>{const{t:e}=ne(),[a,i]=g.useState(!1),n=N(C=>C.settingsConfig),r=N(C=>C.filters);n.dateFormat;const c=_(C=>C.setFilters);de().add(-7,"d"),de(),de().add(-14,"d"),de(),de().add(-30,"d"),de(),de().add(-90,"d"),de();const k=C=>{var p,j;if(C){const m=(p=C[0])==null?void 0:p.format("YYYY-MM-DD"),Z=(j=C[1])==null?void 0:j.format("YYYY-MM-DD");c({...r,dateRange:{dateFrom:m??"",dateTo:Z??""}})}else c({...r,dateRange:{dateFrom:"",dateTo:""}})};return t.jsxs(Ba,{$rangePickerOpen:a,children:[t.jsxs("div",{className:"tgg-range-picker-input-wrapper",children:[t.jsx("div",{className:"tgg-border-top"}),t.jsx("div",{className:"tgg-border-bottom"}),t.jsx(_a,{allowClear:!0,picker:"date",className:"tgg-custom-range-picker",onOpenChange:C=>i(C),placeholder:[e("filters.dateFrom"),e("filters.dateTo")],needConfirm:!0,onChange:C=>{C||k(C)},value:[r.dateRange.dateFrom==""?void 0:de(r.dateRange.dateFrom),r.dateRange.dateTo==""?void 0:de(r.dateRange.dateTo)],onOk:C=>k(C),inputReadOnly:!0,open:a,getPopupContainer:()=>document.getElementById("tgg-picker-dropdown-wrapper")}),t.jsx("div",{className:"tgg-attachment"}),t.jsx("div",{className:"tgg-side-border"})]}),t.jsx("div",{className:"tgg-picker-dropdown-wrapper",id:"tgg-picker-dropdown-wrapper"})]})},Qa=G.div.attrs({className:"tgg-info-filter"})`
	position: relative;

	display: flex;
	justify-content: start;
	align-items: center;

	background-color: var(--background-secondary);

	user-select: none;

	.tgg-active-icon {
		position: absolute;

		right: 12.5px;

		svg {
			font-size: 1.25em;
			opacity: 0.55;
		}

		display: none;
	}

	${({$active:e})=>e?`

		.tgg-active-icon {
			display: flex;
		}

		&:before {
			content: '';
			position: absolute;

			left: 0;

			top: 50%;
			bottom: 50%;
			transform: translateY(-50%);

			height: 50%;
			width: 3px;

			background-color: ${w.button.secondaryFilterBorderColor};
			filter: drop-shadow(5px 5px 5px ${w.main.secondaryColor});
		}

		color: ${w.main.secondaryColor};
		box-shadow: 1.5px 0px 2.5px 1.5px ${w.button.secondaryFilterBorderColor};
		
		transition: box-shadow 0.25s ease-in-out;
		&:hover {
			cursor: pointer;
			box-shadow: 4.5px 0px 7.5px 4.5px ${w.button.secondaryFilterBorderColor};
		}
		`:`
		color: ${w.main.primaryColor};
		box-shadow: 1.5px 0px 2.5px 1.5px ${w.button.primaryFilterBorderColor};
		
		transition: box-shadow 0.25s ease-in-out;
		&:hover {
			cursor: pointer;

			box-shadow: 3.5px 0px 7.5px 3.5px ${w.button.primaryFilterBorderColor};
		}
	`};

	height: 45px;
	width: 95%;

	overflow: hidden;

	.tgg-label {
		line-height: 1em;
		font-size: 1em;

		padding-left: 1.25em;

		> span {
			font-weight: 600;
		}
	}

	.tgg-side-border {
		position: absolute;

		height: 100%;
		width: 20px;

		border-radius: 0 17.5px 17.5px 0;
	}

	${({$direction:e,$active:a})=>e==="left"?`
			border-top-right-radius: 17.5px;
			border-bottom-right-radius: 17.5px;

			.tgg-side-border {
				right: 0;

				border-top: 1px solid ${w.main.primaryColor};
				border-right: 1px solid ${w.main.primaryColor};
				border-bottom: 1px solid ${w.main.primaryColor};

				${a&&`border-color: ${w.main.secondaryColor};`};

				overflow: hidden;
			}

			.tgg-attachment {
				position: absolute;
				right: -2px;
				top: 50%;
				bottom: 50%;
				transform: translateY(-50%);

				height: 50%;
				width: 5px;

				background-color: ${w.main.primaryColor};
				filter: drop-shadow(-1px 0px 5px ${w.main.primaryColor});

				${a&&`
					background-color: ${w.main.secondaryColor};
					filter: drop-shadow(-1px 0px 5px ${w.main.secondaryColor});	
				`};
			}

			.tgg-border-top,
			.tgg-border-bottom {
				background: linear-gradient(
					90deg,
					rgba(22, 26, 32, 0) 0%,
					${w.main.primaryColor} 90%);

				${a&&`
					background: linear-gradient(
						90deg,
						rgba(22, 26, 32, 0) 0%,
						${w.main.secondaryColor} 90%);
				`};
			}
			`:`
			border-top-left-radius: 17.5px;
			border-bottom-left-radius: 17.5px;

			.tgg-side-border {
				left: 0;

				width: 20px;

				transform: rotate(180deg);

				border-top: 1px solid ${w.main.primaryColor};
				border-right: 1px solid ${w.main.primaryColor};
				border-bottom: 1px solid ${w.main.primaryColor};
			}

			.tgg-attachment {
				position: absolute;
				left: -2px;
				top: 50%;
				bottom: 50%;
				transform: translateY(-50%);

				height: 50%;
				width: 6px;

				background-color: ${w.main.primaryColor};
				filter: drop-shadow(-1px 0px 5px ${w.main.primaryColor});
			}

			.tgg-border-top,
			.tgg-border-bottom {
				background: linear-gradient(
					90deg, 
					${w.main.primaryColor} 0%,
					rgba(22, 26, 32, 0) 90%);
			}
	`}

	.tgg-border-top,
	.tgg-border-bottom {
		position: absolute;

		height: 1px;
		width: 100%;
	}

	.tgg-border-top {
		top: 0;
	}

	.tgg-border-bottom {
		bottom: 0;
	}
`,qe=({label:e,active:a,onClick:i,direction:n="left"})=>{const r=()=>{const[c,k]=e.split("(");return k?t.jsxs(t.Fragment,{children:[c,t.jsxs("span",{children:["(",k]})]}):t.jsx(t.Fragment,{children:c})};return t.jsxs(Qa,{$direction:n,$active:a,onClick:i,children:[t.jsx("div",{className:"tgg-border-top"}),t.jsx("div",{className:"tgg-border-bottom"}),t.jsx("div",{className:"tgg-side-border"}),t.jsx("div",{className:"tgg-attachment"}),t.jsx("div",{className:"tgg-label",children:r()}),t.jsx("div",{className:"tgg-active-icon",children:t.jsx(qt,{})})]})},Ma=G.div.attrs({className:"tgg-sidebar"})`
	width: 15.5%;
	height: 100%;

	padding-right: 0.25em;
	padding-bottom: 30px;

	.tgg-filters-container {
		height: calc(100% - ${e=>e.$playerInfoContainerHeight}px);

		.tgg-invoices-filters-container {
			display: flex;

			flex-direction: column;

			gap: 1em;

			.tgg-separator {
				position: relative;

				display: flex;
				align-items: center;

				gap: 7.5px;

				width: 87.5%;

				margin-left: 0.75em;

				padding: 0.25em 0;

				user-select: none;

				.tgg-separator-line-1 {
					height: 1.5px;
					width: 25%;

					border-radius: 20px;

					background-color: var(--color-primary);
					box-shadow: 0px 0px 5px 0px var(--color-primary);
				}

				.tgg-label {
					color: ${w.main.primaryTextColor};
					font-size: 0.85em;
				}

				.tgg-separator-line-2 {
					height: 1.5px;
					width: 85%;

					border-radius: 20px;

					background-color: var(--color-secondary);
					box-shadow: 0px 0px 5px 0px var(--color-secondary);
				}
			}

			.tgg-personal-btn-wrapper {
				position: relative;

				height: 100%;
				width: 100%;

				.tgg-new-invoice-icon {
					position: absolute;

					top: -2.5px;
					right: 7.5px;

					height: 15px;
					width: 15px;

					border-radius: 50%;
					background-color: var(--color-primary);

					opacity: 0.85;

					box-shadow: 0px 0px 5px 0px var(--color-primary);

					z-index: 1;
				}
			}
		}
	}

	.tgg-player-info-container {
		position: relative;

		display: flex;
		gap: 0.5em;

		width: 90%;

		background-color: var(--background-secondary);

		padding: 0.75em;

		border-radius: 20px;

		margin: 0 auto;

		overflow: hidden;

		box-shadow: 0px 0px 5px 0px var(--color-primary-50);

		.tgg-border-top,
		.tgg-border-bottom {
			position: absolute;

			left: 50%;
			right: 50%;
			transform: translateX(-50%);
			width: 80%;

			height: 1px;

			background: linear-gradient(
				90deg,
				var(--color-primary-75) 0%,
				var(--color-primary-25) 30%,
				var(--background-main) 50%,
				var(--color-primary-25) 70%,
				var(--color-primary-75) 100%
			);
		}

		.tgg-border-top {
			top: 0;
		}

		.tgg-border-bottom {
			bottom: 0;
		}

		.tgg-btn-addon-right,
		.tgg-btn-addon-left {
			position: absolute;
			top: 0;

			width: 20.5px;
			height: 100%;
		}

		.tgg-btn-addon-right {
			right: 0;

			border-top-right-radius: 20px;
			border-bottom-right-radius: 20px;

			border-left: 0;
			border-top: 1px solid var(--color-primary-75);
			border-bottom: 1px solid var(--color-primary-75);
			border-right: 2px solid var(--color-primary-75);
		}

		.tgg-btn-addon-left {
			left: 0;

			border-top-left-radius: 20px;
			border-bottom-left-radius: 20px;

			border-right: 0;
			border-top: 1px solid var(--color-primary-75);
			border-bottom: 1px solid var(--color-primary-75);
			border-left: 2px solid var(--color-primary-75);
		}

		.tgg-info-row {
			display: flex;
			align-items: center;

			width: 100%;

			overflow: hidden;

			.tgg-avatar {
				display: flex;
				justify-content: center;
				align-items: center;

				height: 3.25em;
				width: 3.25em;
				border-radius: 50%;

				overflow: hidden;

				img {
					height: 100%;
					width: 100%;
					object-fit: cover;
				}
			}

			.tgg-info {
				display: flex;
				flex-direction: column;

				justify-content: center;
				align-items: start;

				row-gap: 0.25em;

				color: #fff;

				overflow: hidden;

				.tgg-name {
					white-space: nowrap;
					text-overflow: ellipsis;
					overflow: hidden;

					width: 100%;

					font-size: 1.1em;
					font-weight: 600;
				}

				.tgg-money {
					white-space: nowrap;
					text-overflow: ellipsis;
					overflow: hidden;

					width: 100%;

					font-size: 0.95em;
					color: var(--color-primary);
				}
			}
		}
	}
`,za=()=>{var M;const{t:e}=ne(),a=g.useRef(null),[i,n]=g.useState(0),[r,c]=g.useState(!1),k=N(f=>f.settingsConfig),C=N(f=>f.companyConfig),p=N(f=>f.totalInvoices),j=N(f=>f.hasNewInvoice),m=N(f=>f.playerData),Z=N(f=>f.jobInfo),q=N(f=>f.filters),y=N(f=>f.mugshot),o=k.currencyFormat,P=_(f=>f.setFilters);_(f=>f.setMugshot);const h=_(f=>f.setHasNewInvoice);g.useLayoutEffect(()=>{var f;a.current&&n((f=a.current)==null?void 0:f.offsetHeight)},[]);const d=f=>{r||q.type===f||(f===K.Personal&&j&&h(!1),P({...q,type:f}),c(!0),setTimeout(()=>{c(!1)},750))},I=f=>{r||q.status===f||(P({...q,status:f}),c(!0),setTimeout(()=>{c(!1)},750))},u=()=>{var $;const f=C==null?void 0:C.create,z=($=Z==null?void 0:Z.grade)==null?void 0:$.level;return(C==null?void 0:C.jobIdentifier)=="other"?!1:!!(f&&f.length>0&&(f.includes("-1")||z&&f.includes(z)||f.includes(K.Personal)))};return t.jsxs(Ma,{$playerInfoContainerHeight:i,children:[t.jsx("div",{className:"tgg-filters-container",children:t.jsxs("div",{className:"tgg-invoices-filters-container",id:"tgg-invoices-filters-container",children:[t.jsxs("div",{className:"tgg-separator",children:[t.jsx("div",{className:"tgg-separator-line-1"}),t.jsx("div",{className:"tgg-label",children:e("filters.filterType")}),t.jsx("div",{className:"tgg-separator-line-2"})]}),t.jsxs("div",{className:"tgg-personal-btn-wrapper",children:[j&&t.jsx("div",{className:"tgg-new-invoice-icon"}),t.jsx(qe,{active:q.type===K.Personal,label:e("filters.myInvoices"),onClick:()=>d(K.Personal)})]}),u()&&t.jsx(qe,{active:q.type===K.Society,label:e("filters.societyInvoices"),onClick:()=>d(K.Society)}),t.jsxs("div",{className:"tgg-separator",children:[t.jsx("div",{className:"tgg-separator-line-1"}),t.jsx("div",{className:"tgg-label",children:e("filters.filterStatus")}),t.jsx("div",{className:"tgg-separator-line-2"})]}),t.jsx(qe,{active:q.status===v.All,label:`${e("filters.allInvoices")} ${q.status===v.All?`(${p})`:""}`,onClick:()=>I(v.All)}),t.jsx(qe,{label:`${e("filters.paidInvoices")} ${q.status===v.Paid?`(${p})`:""}`,active:q.status===v.Paid,onClick:()=>I(v.Paid)}),t.jsx(qe,{label:`${e("filters.unpaidInvoices")} ${q.status===v.Unpaid?`(${p})`:""}`,active:q.status===v.Unpaid,onClick:()=>I(v.Unpaid)}),t.jsx(qe,{label:`${e("filters.cancelledInvoices")} ${q.status===v.Cancelled?`(${p})`:""}`,active:q.status===v.Cancelled,onClick:()=>I(v.Cancelled)}),t.jsxs("div",{className:"tgg-separator",children:[t.jsx("div",{className:"tgg-separator-line-1"}),t.jsx("div",{className:"tgg-label",children:e("filters.filterRange")}),t.jsx("div",{className:"tgg-separator-line-2"})]}),t.jsx(Za,{})]})}),t.jsxs("div",{className:"tgg-player-info-container",ref:a,children:[t.jsx("div",{className:"tgg-border-top"}),t.jsx("div",{className:"tgg-border-bottom"}),t.jsx("div",{className:"tgg-btn-addon-left"}),t.jsx("div",{className:"tgg-btn-addon-right"}),t.jsxs(Ae,{wrap:!1,className:"tgg-info-row",children:[t.jsx(se,{span:7,children:t.jsx("div",{className:"tgg-avatar",children:y?t.jsx("img",{src:y,alt:"avatar"}):t.jsx(pa,{})})}),t.jsx(se,{span:17,children:t.jsxs("div",{className:"tgg-info",children:[t.jsx("div",{className:"tgg-name",children:m==null?void 0:m.fullName}),t.jsx("div",{className:"tgg-money",children:oe(pe(((M=m==null?void 0:m.money)==null?void 0:M.bank)??0),o)})]})})]})]})]})},$a=G.div.attrs({className:"tgg-loading"})`
	opacity: 0.25;

    .loading .dot {
        background: ${w.main.primaryColor};
    }

	@keyframes spin {
		from {
			transform: translateY(0);
			box-shadow: 0 0 0 ${w.main.primaryColor};
		}

		to {
			transform: translateY(-20px);
			box-shadow: 0 40px 0px ${w.main.secondaryColor};
		}
	}
`,Ta=()=>t.jsx($a,{children:t.jsxs("div",{className:"loading",children:[t.jsx("div",{className:"dot"}),t.jsx("div",{className:"dot"}),t.jsx("div",{className:"dot"}),t.jsx("div",{className:"dot"}),t.jsx("div",{className:"dot"}),t.jsx("div",{className:"dot"})]})}),Fa=G.div.attrs({className:"tgg-invoices-dashboard",id:"tgg-invoices-dashboard"})`
	position: relative;
	height: 100%;
	width: 100%;

	overflow-y: auto;
	overflow-x: hidden;

	.tgg-invoices-wrapper {
		display: flex;
		flex-wrap: wrap;

		justify-content: space-evenly;

		padding: 0 1em;

		height: 100%;

		margin: 10px;
		margin-right: 0;
		margin-left: 0;

		gap: 2.5em;
		row-gap: 2.75em;
	}

	.tgg-empty-result {
		position: absolute;

		top: 20%;

		display: flex;
		flex-direction: column;
		align-items: center;

		width: 100%;

		svg {
			height: 250px;
			width: 250px;
			opacity: 0.2;
			color: ${w.main.primaryColor};
		}

		.tgg-empty-result-text {
			font-size: 1.25em;
			color: ${w.main.primaryTextColor};
		}
	}

	/* Scrollbar styling */
	::-webkit-scrollbar {
		width: 3px;
		height: 3px;

		background-clip: padding-box;
		padding: 1em 0;
	}

	::-webkit-scrollbar-button {
		width: 0px;
		height: 0px;
	}

	::-webkit-scrollbar-thumb {
		background: var(--color-primary);
		border: 0px none var(--color-primary);
		border-radius: 50px;
	}

	::-webkit-scrollbar-thumb:hover {
		background: var(--color-primary);
		opacity: 0.8;
	}

	::-webkit-scrollbar-thumb:active {
		background: var(--color-primary);
	}

	::-webkit-scrollbar-track {
		background: var(--color-primary);
		border: 0px none var(--color-primary);

		border-radius: 50px;
	}

	::-webkit-scrollbar-track:hover {
		background: ${w.main.primaryColor};
	}

	::-webkit-scrollbar-track:active {
		background: ${w.main.primaryColor};
	}

	::-webkit-scrollbar-corner {
		background: transparent;
	}
`,Ve=16,Oa=()=>{const[e,a]=g.useState(!0),[i,n]=g.useState(0),[r,c]=g.useState(!0),k=N(h=>h.totalInvoices),C=N(h=>h.UIVisible),p=N(h=>h.invoices),j=N(h=>h.filters),m=_(h=>h.setInvoices),Z=_(h=>h.setHasNewInvoice),q=_(h=>h.setFlexOasisData),y=_(h=>h.setTotalInvoices),o=h=>ze.slice(Ve*h,Ve*h+Ve);g.useEffect(()=>{C?(P(!0),a(!1)):(m([]),n(0),y(0))},[C]),g.useEffect(()=>{e||P(!0)},[j]);const P=h=>{c(!0);let d=i;h&&(n(0),d=0,m([])),Y("billing:invoice:all",{page:d,filters:j},void 0,{invoices:o(d??i),totalInvoices:100}).then(I=>{y(I==null?void 0:I.totalInvoices),(I==null?void 0:I.totalInvoices)>0&&(I!=null&&I.invoices)?d===0?setTimeout(()=>{m([...I.invoices])},250):m([...p.concat(I.invoices)]):m([]),n((d??i)+1),setTimeout(()=>{c(!1)},250)})};return ke("billing:update-invoices",h=>{if(j.type===K.Personal&&(j.status===v.All||j.status===v.Unpaid)&&(j.society==="all"||j.society==="received")){const d=[...p];d.unshift(h),m([...d])}else Z(!0);q({status:!0,message:"newInvoiceReceived"})}),ke("billing:on-invoice-paid",h=>{const d=[...p],I=d.find(u=>u.id===h.id);I&&(I.status=v.Paid,m([...d])),q({status:!0,message:"onInvoicePaid"})}),ke("billing:on-invoice-cancelled",h=>{const d=[...p],I=d.find(u=>u.id===h);I&&(I.status=v.Cancelled,m([...d])),q({status:!0,message:"onInvoiceCancelled"})}),ke("billing:on-invoice-accepted",h=>{const d=[...p],I=d.find(u=>u.id===h);I&&(I.status=v.Unpaid,m([...d])),q({status:!0,message:"onInvoiceAccepted"})}),ke("billing:on-invoice-rejected",h=>{const d=[...p],I=d.find(u=>u.id===h);I&&(I.status=v.Rejected,m([...d])),q({status:!0,message:"onInvoiceRejected"})}),ke("billing:notify-invoice-acceptance",()=>{q({status:!0,message:"onNotifyAcceptInvoice"})}),t.jsxs(Fa,{children:[t.jsx(At,{dataLength:p.length,next:P,hasMore:p.length<k,loader:t.jsx(t.Fragment,{}),scrollableTarget:"tgg-invoices-dashboard",children:t.jsx("div",{className:"tgg-invoices-wrapper",children:g.useMemo(()=>p&&(p==null?void 0:p.map((h,d)=>t.jsx(Ze,{type:W.Dashboard,invoice:h,body:t.jsx(Ye,{invoice:h,invoiceLocation:W.Dashboard}),footer:t.jsx(Ue,{invoice:h,invoiceLocation:W.Dashboard})},d))),[p])})}),r&&p.length===0&&t.jsx(Ta,{}),!r&&p.length===0&&t.jsx("div",{className:"tgg-empty-result",children:t.jsx(ya,{})})]})},Wa=G.div.attrs({className:"tgg-create-invoice-btn"})`
	position: relative;

	display: flex;
	justify-content: start;
	align-items: center;

	height: 47.5px;
	min-width: 100px;
	width: auto;

	padding: 0 1em;

	${({$withIcon:e})=>e?"padding-right: 5em;":"justify-content: center;"}

	border: 1px solid var(--color-primary);
	border-radius: 15px;

	border-right: none;

	overflow: hidden;

	box-shadow: 0px 0px 2.5px 0px var(--color-primary);

	transition: all 0.25s ease-in-out;
	&:hover {
		cursor: pointer;
		box-shadow: 0px 0px 7.5px 0px var(--color-primary);
	}

	.tgg-text {
		color: var(--color-primary);
		font-weight: 600;
		font-size: 1.1em;
		line-height: 1em;
	}

	.tgg-icon-wrapper {
		svg {
			color: var(--color-primary);
			filter: opacity(0.9);
		}

		svg:first-child {
			position: absolute;

			right: 10px;
			bottom: -5px;
		}

		svg:last-child {
			position: absolute;

			right: 18.5px;
			bottom: -8.5px;
			filter: opacity(0.2);
		}
	}

	.tgg-right-attachment {
		position: absolute;
		right: 0;

		background: linear-gradient(
			0deg,
			var(--color-primary-15) 0%,
			rgba(6, 23, 38, 0.5) 50%,
			var(--color-primary-15) 100%
		);

		height: 100%;
		width: 2px;
	}

	.tgg-left-attachment {
		position: absolute;
		left: -3px;
		top: 50%;
		bottom: 50%;
		transform: translateY(-50%);

		height: 50%;
		width: 5px;

		background-color: var(--color-primary);
		filter: drop-shadow(-1px 0px 5px var(--color-primary));
	}
`,et=({onClick:e,text:a,withIcon:i})=>{const{t:n}=ne();return t.jsxs(Wa,{onClick:e,$withIcon:i,children:[t.jsx("div",{className:"tgg-left-attachment"}),t.jsx("div",{className:"tgg-right-attachment"}),t.jsx("div",{className:"tgg-text",children:n(a)}),i&&t.jsxs("div",{className:"tgg-icon-wrapper",children:[t.jsx(De,{}),t.jsx(De,{})]})]})},Ea=G.div.attrs({className:"tgg-content"})`
	display: flex;

	flex-direction: column;

	width: 100%;
	height: 100%;

	overflow: hidden;

	height: 100%;
	width: 85%;

	background-color: var(--background-secondary);

	border-top-left-radius: 25px;

	.tgg-content-wrapper {
		display: flex;
		flex-direction: column;

		height: inherit;

		padding: 1em 0.75em 0 0;

		.tgg-header-section {
			.tgg-create-invoice-col {
				display: flex;

				gap: 1em;

				justify-content: end;
			}

			.tgg-searchbar {
				position: relative;

				display: flex;

				justify-content: center;
				align-items: center;

				width: 100%;
				height: 100%;

				input {
					height: 37.5px;
					width: 100%;

					padding: 0 1em;

					outline: none;
					border: none;
					border-radius: 15px;

					background-color: var(--background-main);

					&::placeholder {
						color: #969696;
						font-family: 'Poppins', sans-serif;
						font-weight: 500;
					}

					color: ${w.main.secondaryTextColor};

					font-size: 1.1em;
					line-height: 1em;

					&:focus {
						box-shadow: 0 0 2.5px 0.5px var(--color-primary);
					}
				}

				.tgg-input-addon-icon-btn {
					position: absolute;

					display: flex;
					align-items: center;

					height: 100%;

					right: 10px;

					background: transparent;
					border: none;
					outline: none;

					svg path {
						color: var(--color-primary);
					}

					svg {
						transition: transform 0.15s ease-in-out;
					}

					&:disabled {
						cursor: not-allowed;
					}

					&:hover:not(:disabled) {
						cursor: pointer;

						svg {
							transform: scale(1.175);
							filter: opacity(0.75);
						}
					}
				}
			}
		}

		.tgg-body-section {
			position: relative;

			height: calc(
				100% - ${({$headerHeight:e})=>e}px
			);
			overflow: hidden;

			padding: 1em 0 0 0.75em;

			margin-bottom: 2em;

			.tgg-box-shadow {
				position: absolute;
				bottom: 0;
				height: 70px;
				width: 100%;

				z-index: 2;

				-webkit-box-shadow: inset 0px -35px 25px -30px rgba(0, 0, 0, 0.75);
				-moz-box-shadow: inset 0px -35px 25px -30px rgba(0, 0, 0, 0.75);
				box-shadow: inset 0px -35px 25px -30px rgba(0, 0, 0, 0.75);
			}
		}
	}

	.tgg-filters-left {
		display: flex;

		gap: 1em;

		.tgg-select {
			height: 100%;

			.ant-select-selector {
				display: flex;
				align-items: center;

				border: 1px solid var(--color-primary);
				border-left: none;

				border-top-left-radius: 0;
				border-bottom-left-radius: 0;

				border-top-right-radius: 15px;
				border-bottom-right-radius: 15px;

				${({$dropdownOpen:e})=>e&&`
				border-bottom-right-radius: 0;
			`}

				outline: none;

				box-shadow: 0 0 2.5px 0.5px var(--color-primary);

				height: 100%;

				background-color: var(--background-secondary);

				.ant-select-selection-search-input {
					::placeholder {
						color: ${w.main.secondaryTextColor};
					}

					font-size: 1em;
					color: ${w.main.secondaryTextColor} !important;
				}

				.ant-select-selection-item {
					color: var(--color-primary);
				}

				.ant-select-item-empty {
					.ant-empty-image {
						svg {
							ellipse {
								display: none;
							}

							g {
								stroke: rgba(255, 255, 255, 0.1);

								fill: var(--color-primary);

								path:first-child {
									fill: #161a2f;
								}

								path:last-child {
									fill: #242a4a;
								}
							}
						}
					}

					.ant-empty-description {
						color: ${w.main.primaryTextColor};
						font-size: 1.1em;
						font-weight: 600;
					}
				}

				.ant-select-dropdown {
					will-change: transform;

					top: 46px !important;
					border-bottom-right-radius: 15px;
					border-bottom-left-radius: 0;

					border-top-left-radius: 0;
					border-top-right-radius: 0;

					background-color: var(--background-secondary);

					border-top: 1px solid var(--color-primary);
					border-right: 1px solid var(--color-primary);
					border-bottom: 1px solid var(--color-primary);

					box-shadow: 0px 0px 2.5px 0.5px var(--color-primary);

					.ant-select-item {
						background-color: var(--background-secondary);
						padding: 0;

						&:last-child {
							.tgg-separator {
								display: none;
							}
						}
					}

					.ant-select-item-option-content {
						color: ${w.main.primaryTextColor};
					}

					.ant-select-item-option-selected {
						.tgg-option {
							color: var(--color-primary);
						}
					}

					.tgg-dropdown-option {
						position: relative;

						.tgg-separator {
							width: 90%;
							height: 2px;

							margin-left: 0.5em;

							box-shadow: 0px 0px 2.5px 0.5px var(--color-primary);

							background-color: var(--color-primary);

							filter: opacity(0.45);
						}

						.tgg-option {
							padding: 0.65em 2.5em 0.65em 0.5em;

							overflow: hidden;
							text-overflow: ellipsis;
							white-space: nowrap;

							transition:
								opacity,
								color 0.3s ease-in-out;
							&:hover {
								color: var(--color-primary);
								opacity: 0.85;
							}
						}

						.tgg-selected-icon {
							position: absolute;

							right: 10px;
							top: 50%;

							transform: translateY(-50%);

							display: flex;
							align-items: center;

							height: 100%;

							svg {
								line-height: 1em;
								font-size: 1.75em;
								color: var(--color-primary);
								opacity: 0.85;
							}
						}
					}

					.rc-virtual-list-scrollbar {
						width: 4px !important;

						.rc-virtual-list-scrollbar-thumb {
							background-color: var(--color-primary) !important;
						}
					}
				}

				&:before {
					content: '';
					position: absolute;

					top: 50%;
					bottom: 50px;
					transform: translateY(-50%);

					left: 0;

					height: 20px;
					width: 2.5px;

					background-color: var(--color-primary);
				}
			}

			.ant-select-arrow {
				font-size: 1em;
				font-weight: 600;

				display: flex;
				align-items: center;

				color: var(--color-primary);

				transition: transform 0.5s ease-in-out;

				${({$dropdownOpen:e})=>e&&`
				transform: rotate(360deg);
			`}
			}
		}

		.tgg-filter-btn {
			position: relative;

			display: flex;
			align-items: center;
			justify-content: center;

			svg {
				width: 27.5px;
				height: 25.5px;

				path {
					stroke: var(--color-primary);
				}
			}

			height: 47.5px;
			width: 47.5px;

			background-color: var(--background-main);

			border-radius: 15px;
			border: 1px solid var(--color-primary);

			box-shadow: 0 0 1.5px 0.5px var(--color-primary);

			transition: border-radius 0.25s ease-in-out;
			&:hover {
				cursor: pointer;

				background-color: var(--background-main);

				box-shadow: 0 0 1.5px 1px var(--color-primary);
			}

			${({$orderByDropdownOpen:e})=>e&&"border-radius: 15px 15px 0 0;"}

			.ant-dropdown {
				.ant-dropdown-menu {
					position: absolute;
					top: -5px;
					background-color: var(--background-main) !important;
					box-shadow: 0 0 1.5px 0.5px var(--color-primary);

					border-top-left-radius: 0;
					border: 1px solid var(--color-primary);

					.ant-dropdown-menu-item {
						color: #fff;
						font-size: 1em;

						text-align: start;

						&:hover {
							color: var(--color-primary);
							background-color: transparent !important;
						}

						&.ant-dropdown-menu-item-selected {
							background-color: transparent;
							color: var(--color-primary);
							font-weight: 600;
						}
					}
				}
			}
		}
	}

	::-webkit-scrollbar {
		width: 3px;
		height: 3px;

		background-clip: padding-box;
		padding: 1em 0;
	}

	::-webkit-scrollbar-button {
		width: 0px;
		height: 0px;
	}

	::-webkit-scrollbar-thumb {
		background: var(--color-primary);
		border: 0px none var(--color-primary);
		border-radius: 50px;
	}

	::-webkit-scrollbar-thumb:hover {
		background: var(--color-primary);
		opacity: 0.8;
	}

	::-webkit-scrollbar-thumb:active {
		background: var(--color-primary);
	}

	::-webkit-scrollbar-track {
		background: var(--color-primary);
		border: 0px none var(--color-primary);

		border-radius: 50px;
	}

	::-webkit-scrollbar-track:hover {
		background: var(--color-primary);
	}

	::-webkit-scrollbar-track:active {
		background: var(--color-primary);
	}

	::-webkit-scrollbar-corner {
		background: transparent;
	}
`,Va=()=>{const{t:e}=ne(),a=g.useRef(null),[i,n]=g.useState(0),[r,c]=g.useState(!1),[k,C]=g.useState(!1),[p,j]=g.useState(!1),[m,Z]=g.useState(""),[q,y]=g.useState([]),o=N(b=>b.settingsConfig),P=N(b=>b.playerData),h=N(b=>b.invoices),d=N(b=>b.filters),I=o.currencyFormat,u=_(b=>b.setViewInvoice),M=_(b=>b.setCustomModal),f=_(b=>b.setPlayerData),z=_(b=>b.setInvoices),$=_(b=>b.setFilters),ce=_(b=>b.setViewInvoiceModalOpen),x=_(b=>b.setFlexOasisData),A=_(b=>b.setCreateInvoiceModalOpen),E=[{key:"all",value:"all",label:e("filters.all")},{key:"byMe",value:"byMe",label:e("filters.byMe")}];g.useEffect(()=>{if(d.type===K.Personal){$({...d,society:"all"});const b=((o==null?void 0:o.societyFilters)||[]).map(F=>({key:F.value,value:F.value,label:F.label}));y(b)}else d.type===K.Society&&(y(E),$({...d,society:"all"}))},[d.type,o==null?void 0:o.societyFilters]),g.useLayoutEffect(()=>{a.current&&n(a.current.clientHeight)},[a.current]);const D=b=>{$({...d,society:b})},ie=[{key:"newest",label:e("filters.newest"),onClick:()=>V(Ne.Newest)},{key:"oldest",label:e("filters.oldest"),onClick:()=>V(Ne.Oldest)},{key:"amountDesc",label:e("filters.amountDesc"),onClick:()=>V(Ne.AmountDesc)},{key:"amountAsc",label:e("filters.amountAsc"),onClick:()=>V(Ne.AmountAsc)}],V=b=>{$({...d,orderBy:b})},H=N(b=>b.companyConfig),X=N(b=>b.jobInfo),T=()=>{var le;const b=H==null?void 0:H.create,F=(le=X==null?void 0:X.grade)==null?void 0:le.level;if(!b||b.length===0)return!1;if(d.type==K.Society){if(b.includes("-1")||F&&b.includes(F))return!0}else if(d.type==K.Personal&&b.includes(K.Personal))return!0;return!1},ve=b=>{var F;return(F=b==null?void 0:b.replace(/\s+/g,""))==null?void 0:F.trim()},ue=()=>{if(!(m!=null&&m.trim())||r)return;const b=ve(m);c(!0),Y("billing:invoice:search-by-uuid",b,void 0,ze[0]).then(F=>{F?(u(F),ce(re.Open),Z("")):(x({status:!0,message:"invoiceNotFound"}),Z("")),setTimeout(()=>{c(!1)},1e3)})},je=b=>{var F,le;if(o.allowOverdraft&&((F=P==null?void 0:P.money)!=null&&F.bank)){const s=P.money.bank,S=b,O=o.overdraftLimit;if(s-S<-O){x({status:!0,message:"exceedingOverdraftLimit"}),M(null);return}}else if((le=P==null?void 0:P.money)!=null&&le.bank&&P.money.bank<b){x({status:!0,message:"insufficientFunds"}),M(null);return}Y("billing:invoice:pay-all",b,void 0,!0).then(s=>{var S;if(s){if(P&&f({...P,money:{...P.money,bank:((S=P.money)==null?void 0:S.bank)-b}}),d.status===v.Unpaid||d.status===v.All){const O=[...h];O.forEach(ee=>{ee.status===v.Unpaid&&(ee.status=v.Paid)}),z(O)}x({status:!0,message:"payAllSuccess"})}else x({status:!0,message:"payAllFailed"});M(null)})},he=()=>{Y("billing:invoice:get-total-payment-amount",null,void 0,1e3).then(b=>{if(b===0)x({status:!0,message:"noInvoicesToPay"});else{const F=oe(pe(b),I);M({visible:!0,bodyText:e("invoice.payAllConfirm",{totalAmount:F}),onOk:()=>je(b),onCancel:()=>M(null)})}})};return t.jsx(Ea,{$headerHeight:i,$dropdownOpen:p,$orderByDropdownOpen:k,children:t.jsxs("div",{className:"tgg-content-wrapper",children:[t.jsx("div",{className:"tgg-header-section",ref:a,children:t.jsxs(Ae,{children:[t.jsxs(se,{span:6,className:"tgg-filters-left",children:[t.jsx(Me,{showSearch:!0,className:"tgg-select",style:{width:190},value:d==null?void 0:d.society,onSelect:D,open:p,filterOption:(b,F)=>{var le;return(((le=F==null?void 0:F.label)==null?void 0:le.toLowerCase())??"").includes(b.toLowerCase())},onDropdownVisibleChange:b=>j(b),options:q,getPopupContainer:b=>b,optionRender:b=>t.jsxs("div",{className:"tgg-dropdown-option",children:[b.key===(d==null?void 0:d.society)&&t.jsx("div",{className:"tgg-selected-icon",children:t.jsx(_t,{})}),t.jsx("div",{className:"tgg-option",children:b.label}),t.jsx("div",{className:"tgg-separator"})]})}),t.jsx(Bt,{trigger:["click"],mouseEnterDelay:0,mouseLeaveDelay:0,open:k,getPopupContainer:b=>b,className:"tgg-filter-btn",menu:{items:ie,selectable:!0,defaultSelectedKeys:[Ne.Newest],selectedKeys:[d==null?void 0:d.orderBy]},onOpenChange:b=>C(b),placement:"bottomLeft",children:t.jsx(tt,{icon:t.jsx(ga,{})})})]}),t.jsx(se,{span:10,children:t.jsxs("div",{className:"tgg-searchbar",children:[t.jsx("input",{type:"text",onKeyDown:b=>{b.key==="Enter"&&!r&&ue()},value:m,onChange:b=>Z(b.target.value),placeholder:e("filters.searchPlaceholder")}),t.jsx("button",{onClick:ue,className:"tgg-input-addon-icon-btn",disabled:!m.trim().length||r,children:t.jsx(ma,{})})]})}),t.jsxs(se,{span:8,className:"tgg-create-invoice-col",children:[d.type===K.Personal&&t.jsx(et,{text:"general.payAll",onClick:he}),T()&&t.jsx(et,{text:"invoice.create",withIcon:!0,onClick:()=>A(ge.Open)})]})]})}),t.jsxs("div",{className:"tgg-body-section",children:[t.jsx(Oa,{}),h.length>4&&t.jsx("div",{className:"tgg-box-shadow"})]})]})})},Ha=G.div.attrs({className:"tgg-dynamic-island"})`
	position: absolute;

	left: 50%;
	top: 12.5px;
	transform: translateX(-50%);

	width: calc(100% / 3);
	height: 30px;

	z-index: 999;

	img {
		position: relative;
		object-fit: contain;
		width: 100%;
		height: 100%;
		z-index: 3;

		left: 0;

		user-select: none;
		pointer-events: none;
	}

	.tgg-dynamic-expand {
		position: absolute;

		top: 0;

		left: 50%;
		transform: translateX(-50%);

		transition-property: width, height;
		transition-duration: 0.7s;
		transition-timing-function: ease-in-out;

		width: 130px;
		height: 30px;

		background-color: #000;

		border-radius: 50px;
		border: 1px solid #ffffff1a;

		overflow: hidden;

		z-index: 2;

		display: flex;

		padding: 10px 15px;

		.tgg-oasis-row {
			width: 100%;

			.tgg-oasis-col {
				display: flex;
				align-items: center;
			}
		}

		.tgg-dynamic-island-content {
			display: flex;
			align-items: center;
			gap: 12.5px;

			height: 100%;
			width: 100%;

			.tgg-icon {
				position: relative;

				display: flex;
				justify-content: center;
				align-items: center;

				width: 50px;
				height: 50px;

				border-radius: 50%;

				pointer-events: none;
				opacity: 0;

				will-change: transform;

				svg {
					width: 100%;
					height: 100%;
				}
			}

			.tgg-message {
				font-size: 1em;
				font-weight: 600;
				color: #fff;

				user-select: none;
				pointer-events: none;
				opacity: 0;

				will-change: transform;
			}
		}

		${({$expanded:e})=>e?`
            width: 325px;

            .tgg-dynamic-island-content {
                transition: opacity 0.5s ease-in-out;

                .tgg-icon, 
                .tgg-message {
                    transition: 0.5s ease-in-out;
				    transition-delay: 0.4s;
                    opacity: 1;
                }
            }
        `:`
                .tgg-icon, 
                .tgg-message {
                    transition-delay: 0.5s;
				    transition: 0.25s ease-in-out;
                }
        `}
	}
`,Ra=()=>{const{t:e}=ne(),[a,i]=g.useState(30),[n,r]=g.useState(null),c=N(p=>p.flexOasisData),k=_(p=>p.setFlexOasisData);g.useEffect(()=>{if(c.status){let p=setTimeout(()=>{k({status:!1})},c.timeout??3e3);r(p)}else k({status:!1,message:void 0,timeout:-1}),clearTimeout(n);return()=>{clearTimeout(n)}},[c.status]),g.useEffect(()=>{C()},[c.status]);const C=()=>{let p=0;!c.message||!c.status?p=30:c.message.length<=30?p=75:c.message.length<=50?p=85:c.message.length<=70?p=97.5:c.message.length<=85?p=105:c.message.length<=200&&(p=135),i(p)};return t.jsxs(Ha,{$expanded:c.status,children:[t.jsx("img",{src:"utils/camera.png",alt:""}),t.jsx("div",{className:"tgg-dynamic-expand",style:{height:`${a}px`},children:t.jsx("div",{className:"tgg-dynamic-island-content",children:t.jsxs(Ae,{className:"tgg-oasis-row",children:[t.jsx(se,{span:5,className:"tgg-oasis-col",children:t.jsx("div",{className:"tgg-icon",children:t.jsx(ha,{})})}),t.jsx(se,{span:19,className:"tgg-oasis-col",children:t.jsx("div",{className:"tgg-message",children:c.message&&e(`notifications.${c.message}`)})})]})})})]})},Ya=G.header`
	position: relative;

	display: flex;

	justify-content: space-between;
	align-items: center;

	padding: 0 1em;

	width: 100%;
	min-height: 6.5%;

	border-bottom: 1px solid var(--color-primary-75);

	.tgg-menu-type {
		font-size: 1em;
		font-weight: 600;

		color: ${w.main.primaryTextColor};
	}

	.tgg-buttons-wrapper {
		position: relative;

		display: flex;
		gap: 0.5em;

		.tgg-header-btn {
			display: flex;
			justify-content: center;
			align-items: center;

			height: 1.75em;
			width: 1.75em;

			background-color: var(--background-secondary);

			border-radius: 10px;

			transition: all 0.3s;

			aspect-ratio: 1/1;

			border: 1px solid transparent;

			&:hover {
				cursor: pointer;

				border: 1px solid var(--color-primary-50);
			}

			svg {
				color: var(--color-primary);
			}

			&.tgg-close svg {
				font-size: 1.75em;
				color: var(--color-primary);
			}

			&.tgg-settings svg {
				font-size: 1em;
				color: ${w.button.headerIconLightColor};
			}

			&.tgg-more {
				&.tgg-expanded {
					border: 1px solid var(--color-primary-50);
					box-shadow: 0 0 5px 0 var(--color-primary-50);

					svg {
						transform: rotate(90deg);
					}
				}

				svg {
					transition: transform 0.3s ease-in-out;
					font-size: 1.2em;
					color: ${w.button.headerIconLightColor};
				}
			}

			&.tgg-statistics svg {
				font-size: 0.9em;
				color: ${w.button.headerIconLightColor};
			}

			&.tgg-admin svg {
				font-size: 1.15em;
				color: ${w.button.headerIconLightColor};
			}
		}
	}

	.tgg-more-actions {
		gap: 0.25em;

		width: 0;
		display: none;

		&.tgg-expanded {
			display: flex;

			width: auto;
		}
	}
`,Ua=()=>{var j;const[e,a]=g.useState(!1),i=N(m=>m.jobInfo),n=i==null?void 0:i.label,r=(j=i==null?void 0:i.grade)==null?void 0:j.name,c=_(m=>m.setSettingsDrawerOpen),k=_(m=>m.setStatisticsOpen),C=()=>{Y("billing:close")},p=()=>{a(!e)};return t.jsxs(Ya,{children:[t.jsx("div",{className:"tgg-menu-type",children:n+": "+r}),t.jsx(Ra,{}),t.jsxs("div",{className:"tgg-buttons-wrapper",children:[t.jsxs("div",{className:`tgg-more-actions ${e?"tgg-expanded":"tgg-collapsed"}`,children:[t.jsx("div",{className:"tgg-header-btn tgg-statistics",onClick:()=>{a(!1),k(Ce.Open)},children:t.jsx(Zt,{})}),t.jsx("div",{className:"tgg-header-btn tgg-settings",onClick:()=>c(!0),children:t.jsx(Qt,{})})]}),t.jsx("div",{className:`tgg-header-btn tgg-more${e?" tgg-expanded":""}`,onClick:p,children:t.jsx(it,{})}),t.jsx("div",{className:"tgg-header-btn tgg-close",onClick:C,children:t.jsx(Mt,{})})]})]})},Ga=G.div.attrs({className:"tgg-app-grid"})`
	position: relative;

	display: flex;

	flex-direction: column;

	height: 100%;
	width: 100%;

	background-color: var(--background-main);

	border-radius: 27.5px;

	overflow: hidden;

	.tgg-section-wrapper {
		display: flex;

		height: 93.5%;
		width: 100%;

		padding-top: 1.25em;
	}

	.tgg-payment-confirm-modal-root {
		.ant-modal-mask {
			z-index: 500;
			position: absolute;
			height: 100%;
			width: 100%;

			backdrop-filter: blur(6px);
			background-color: rgba(0, 0, 0, 0.2);
			box-shadow: inset 0 0 200px 1px ${Be.insetShadow};
		}

		.tgg-payment-confirm-modal {
			.ant-modal-content,
			.ant-modal-title {
				background-color: var(--background-main);
			}

			.ant-modal-content {
				padding: 0;
				box-shadow: 0 0 20.5px 0.5px rgba(0, 0, 0, 0.35);

				height: 200px;

				.ant-modal-body {
					height: 100%;

					.tgg-modal-content {
						position: relative;

						height: 100%;
						width: 100%;

						display: flex;
						flex-direction: column;

						justify-content: center;
						align-items: center;

						will-change: transform;

						.tgg-modal-info-icon {
							position: absolute;

							right: 50%;
							left: 50%;
							transform: translateX(-50%);

							top: -35px;

							display: flex;
							justify-content: center;
							align-items: center;

							width: 100px;
							height: 100px;

							padding: 22.5px;

							border-radius: 50%;

							background-color: var(--background-secondary);

							box-shadow: 0 0 20px 0 rgba(0, 0, 0, 0.35);

							svg {
								color: #fff;
							}
						}

						.tgg-modal-body {
							display: flex;

							flex-direction: column;

							justify-content: space-evenly;
							align-items: center;

							width: 100%;

							height: 100%;

							margin-top: 55px;

							will-change: transform;
							.tgg-modal-info-text {
								color: var(--color-primary);

								font-size: 1.15em;
								font-weight: 600;

								text-align: center;

								padding: 0 2em;
							}

							.tgg-modal-buttons {
								display: flex;

								gap: 1em;

								margin-top: 1em;

								.tgg-modal-cancel-btn {
									background-color: transparent;

									color: var(--color-primary);

									font-size: 1em;
									font-weight: 600;

									padding: 0.5em 1em;

									border-radius: 5px;

									outline: none;
									border: none;

									transition: color 0.25s ease-in-out;
									&:hover {
										cursor: pointer;
										color: #fff;
									}
								}

								.tgg-modal-confirm-btn {
									background-color: var(--color-primary);

									color: #fff;

									font-size: 1em;
									font-weight: 600;

									padding: 0.5em 1em;

									border-radius: 5px;

									outline: none;
									border: none;

									transition: box-shadow 0.25s ease-in-out;
									&:hover {
										cursor: pointer;

										box-shadow: 0 0 10px 0 var(--color-primary);
									}
								}
							}
						}
					}
				}
			}
		}
	}
`,Ja=()=>t.jsxs(Ga,{children:[t.jsx(Ua,{}),t.jsxs("div",{className:"tgg-section-wrapper",children:[t.jsx(za,{}),t.jsx(Va,{})]}),t.jsx(ja,{}),t.jsx(Pa,{}),t.jsx(La,{}),t.jsx(Aa,{})]}),Xa=G.div.attrs({className:"tgg-tablet-app"})`
	width: 1520px;
	height: 860px;

	transform: translate3d(0, 0, 0) scale(${e=>e.$resizeBy});

	overflow: hidden;

	border-radius: 30px;
	padding: 0.3em;
	background-color: #000;

	filter: drop-shadow(3px 3px 5px #0000001f);
`,Ka=()=>{const e=N(a=>a.resizeBy);return t.jsxs(Xa,{$resizeBy:e,children:[t.jsx(Ja,{}),t.jsx(Ca,{})]})};Re([{action:"billing:set-visible",data:{visible:Pe(),jobInfo:aa,playerData:ia,companyConfig:na}}],1e3);const Da=()=>{const{i18n:e}=ne(),[a,i]=g.useState(null),[n,r]=g.useState(!1),c=N(x=>x.UIVisible),k=N(x=>x.acceptInvoiceVisible),C=_(x=>x.setPlayerData),p=_(x=>x.setUIVisible),j=_(x=>x.setInvoices),m=_(x=>x.setJobInfo),Z=_(x=>x.setMugshot),q=_(x=>x.setAcceptInvoiceVisible),y=_(x=>x.setSettingsConfig),o=_(x=>x.setTotalInvoices),P=_(x=>x.setCompanyConfig),h=_(x=>x.setQuickCreateInvoiceVisible),d=_(x=>x.setMenuType);g.useEffect(()=>{if(!c)return;const x=A=>{["Escape"].includes(A.code)?Pe()||(A.preventDefault(),Y("billing:close").then(()=>{u()})):["Backquote"].includes(A.code)&&Pe()&&Re([{action:"toggle-dev-menu",data:!0}],0)};return window.addEventListener("keyup",x),()=>window.removeEventListener("keyup",x)},[c]),g.useEffect(()=>{var x;if(document.getElementsByTagName("html")[0].style.visibility="visible",document.getElementsByTagName("body")[0].style.visibility="visible",Pe()&&window.location.hostname==="localhost"){const A=document.getElementById("app");A&&(A.style.backgroundColor="#313131");const E=(x=document.getElementById("app"))==null?void 0:x.style;E&&(E.background="url(utils/bgdummy.jpg) no-repeat")}Y("billing:misc:get-config",null,void 0,sa).then(A=>{if(A){const E=(D,ie)=>{D=D.replace("#","");const V=parseInt(D.substr(0,2),16),H=parseInt(D.substr(2,2),16),X=parseInt(D.substr(4,2),16);return`rgba(${V}, ${H}, ${X}, ${ie})`};A.primaryColor&&(document.documentElement.style.setProperty("--color-primary",A.primaryColor),document.documentElement.style.setProperty("--color-primary-75",E(A.primaryColor,.75)),document.documentElement.style.setProperty("--color-primary-50",E(A.primaryColor,.5)),document.documentElement.style.setProperty("--color-primary-35",E(A.primaryColor,.35)),document.documentElement.style.setProperty("--color-primary-25",E(A.primaryColor,.25)),document.documentElement.style.setProperty("--color-primary-15",E(A.primaryColor,.15)),document.documentElement.style.setProperty("--color-primary-60",E(A.primaryColor,.6))),A.secondaryColor&&(document.documentElement.style.setProperty("--color-secondary",A.secondaryColor),document.documentElement.style.setProperty("--color-secondary-60",E(A.secondaryColor,.6))),A.backgroundMain&&document.documentElement.style.setProperty("--background-main",A.backgroundMain),A.backgroundSecondary&&document.documentElement.style.setProperty("--background-secondary",A.backgroundSecondary),y(A),r(!0),e.changeLanguage(A.language)}})},[]);const I=x=>{x.visible&&(C(x.playerData),m(M(x.jobInfo)),P(f(x.companyConfig)),Z(x==null?void 0:x.mugshot),k&&(q(!1),setTimeout(()=>{Re([{action:"billing:notify-invoice-acceptance",data:null}],100)}))),p(x.visible)},u=()=>{o(0),j([])},M=x=>{const A={...x};return A.grade.level=x.grade.level.toString(),A},f=x=>{var E,D,ie,V,H,X;const A={...x};return A.create=x.create.map(T=>T=T.toString()),A.cancel=x.cancel.map(T=>T=T.toString()),A.acceptCompanyInvoice=((E=x.acceptCompanyInvoice)==null?void 0:E.map(T=>T=T.toString()))??[],A.rejectCompanyInvoice=((D=x.rejectCompanyInvoice)==null?void 0:D.map(T=>T=T.toString()))??[],A.canPayCompanyInvoice=((ie=x.canPayCompanyInvoice)==null?void 0:ie.map(T=>T=T.toString()))??[],A.representativeGrades=((V=x.representativeGrades)==null?void 0:V.map(T=>T=T.toString()))??[],A.createCompanyInvoice=((H=x.createCompanyInvoice)==null?void 0:H.map(T=>T=T.toString()))??[],A.comission=((X=x==null?void 0:x.comission)==null?void 0:X.map(T=>({...T,grade:T.grade.toString()})))??[],A};ke("billing:set-visible",x=>I(x)),g.useEffect(()=>{k||setTimeout(()=>{i(null)},500)},[k]),g.useEffect(()=>{k&&(h(!1),Y("billing:close-quick-create-invoice").catch(()=>{}))},[k,h]);const z=x=>{C(x.playerData),i(x.invoice),setTimeout(()=>{q(!0)},500)};ke("billing:ask-invoice-acceptance",x=>z(x));const $=N(x=>x.quickCreateInvoiceVisible);g.useEffect(()=>{},[$]),g.useEffect(()=>{$&&(q(!1),Y("billing:invoice:rejected").catch(()=>{}))},[$,q]);const ce=x=>{C(x.playerData);const A=M(x.jobInfo),E=f(x.companyConfig);m(A),P(E);const D=()=>{const V=E==null?void 0:E.create;return!!(V!=null&&V.includes("__personal"))};(()=>{var X;const V=E==null?void 0:E.create,H=(X=A==null?void 0:A.grade)==null?void 0:X.level;if(!V||V.length===0)return!1;if(V.includes("-1"))return!0;if(H!=null){const T=H.toString();if(V.includes(T))return!0}return!1})()?d(R.Business):D()?d(R.Personal):d(R.Business),setTimeout(()=>{h(!0),Y("billing:quick-create-invoice-ready")},500)};return ke("billing:open-quick-create-invoice",x=>ce(x)),t.jsx(ei,{children:t.jsxs("div",{id:"app",className:"app","data-theme":"dark",children:[n&&c&&t.jsx(Ka,{}),n&&t.jsx(Kt,{invoice:a}),n&&t.jsx(da,{})]})})},ei=({children:e})=>t.jsx("div",{className:"browser-wrapper",children:e});Ee.use(zt).init({debug:!1,fallbackLng:"en",defaultNS:"translation",interpolation:{escapeValue:!1},resources:{en:{translation:Je("en").then(e=>{Ee.addResourceBundle("en","translation",e)}).catch(e=>{console.error("i18n:Failed to load translations:",e)})},de:{translation:Je("de").then(e=>{Ee.addResourceBundle("de","translation",e)}).catch(e=>{console.error("i18n:Failed to load translations:",e)})}}});const ti=$t.createRoot(document.getElementById("root")),ai=Tt;(window.name==="tgg-billing"||Pe())&&ti.render(t.jsx(ai,{store:Wt,children:t.jsx(Da,{})}));
