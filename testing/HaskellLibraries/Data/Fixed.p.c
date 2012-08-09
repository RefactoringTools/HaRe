#include "newmacros.h"
#include "runtime.h"

#define PS_Data_46Fixed_46MkFixed	((void*)startLabel+24)
#define PS_Data_46Fixed_46E6	((void*)startLabel+52)
#define C0_Data_46Fixed_46E6	((void*)startLabel+64)
#define PS_Data_46Fixed_46E12	((void*)startLabel+100)
#define C0_Data_46Fixed_46E12	((void*)startLabel+112)
#define CT_v1407	((void*)startLabel+192)
#define CT_v1410	((void*)startLabel+272)
#define FN_Data_46Fixed_46fixedResolution	((void*)startLabel+312)
#define CT_v1416	((void*)startLabel+432)
#define F0_Data_46Fixed_46fixedResolution	((void*)startLabel+440)
#define FN_Data_46Fixed_46Prelude_46188_46uf	((void*)startLabel+480)
#define CT_v1419	((void*)startLabel+500)
#define F0_Data_46Fixed_46Prelude_46188_46uf	((void*)startLabel+508)
#define FN_Data_46Fixed_46withDot	((void*)startLabel+540)
#define v1426	((void*)startLabel+550)
#define v1423	((void*)startLabel+554)
#define v1420	((void*)startLabel+564)
#define CT_v1429	((void*)startLabel+656)
#define F0_Data_46Fixed_46withDot	((void*)startLabel+664)
#define FN_LAMBDA1367	((void*)startLabel+696)
#define CT_v1433	((void*)startLabel+740)
#define CF_LAMBDA1367	((void*)startLabel+748)
#define FN_Data_46Fixed_46chopZeros	((void*)startLabel+776)
#define v1434	((void*)startLabel+803)
#define v1438	((void*)startLabel+853)
#define CT_v1450	((void*)startLabel+1064)
#define F0_Data_46Fixed_46chopZeros	((void*)startLabel+1072)
#define FN_LAMBDA1368	((void*)startLabel+1128)
#define CT_v1453	((void*)startLabel+1172)
#define CF_LAMBDA1368	((void*)startLabel+1180)
#define FN_Data_46Fixed_46showIntegerZeros	((void*)startLabel+1212)
#define v1464	((void*)startLabel+1224)
#define v1457	((void*)startLabel+1228)
#define v1454	((void*)startLabel+1256)
#define CT_v1473	((void*)startLabel+1520)
#define F0_Data_46Fixed_46showIntegerZeros	((void*)startLabel+1528)
#define FN_LAMBDA1370	((void*)startLabel+1592)
#define v1474	((void*)startLabel+1610)
#define CT_v1479	((void*)startLabel+1652)
#define F0_LAMBDA1370	((void*)startLabel+1660)
#define FN_LAMBDA1369	((void*)startLabel+1692)
#define CT_v1482	((void*)startLabel+1736)
#define CF_LAMBDA1369	((void*)startLabel+1744)
#define v1483	((void*)startLabel+1856)
#define CT_v1507	((void*)startLabel+2420)
#define FN_Data_46Fixed_46Prelude_46272_46maxnum	((void*)startLabel+2544)
#define CT_v1514	((void*)startLabel+2724)
#define F0_Data_46Fixed_46Prelude_46272_46maxnum	((void*)startLabel+2732)
#define FN_Data_46Fixed_46Prelude_46271_46digits	((void*)startLabel+2784)
#define CT_v1520	((void*)startLabel+2920)
#define F0_Data_46Fixed_46Prelude_46271_46digits	((void*)startLabel+2928)
#define FN_LAMBDA1373	((void*)startLabel+2968)
#define CT_v1523	((void*)startLabel+2988)
#define F0_LAMBDA1373	((void*)startLabel+2996)
#define FN_LAMBDA1372	((void*)startLabel+3024)
#define CT_v1526	((void*)startLabel+3044)
#define F0_LAMBDA1372	((void*)startLabel+3052)
#define FN_LAMBDA1371	((void*)startLabel+3080)
#define CT_v1530	((void*)startLabel+3124)
#define CF_LAMBDA1371	((void*)startLabel+3132)
#define CT_v1535	((void*)startLabel+3264)
#define CT_v1540	((void*)startLabel+3384)
#define CT_v1545	((void*)startLabel+3508)
#define CT_v1550	((void*)startLabel+3632)
#define CT_v1555	((void*)startLabel+3760)
#define CT_v1560	((void*)startLabel+3892)
#define CT_v1565	((void*)startLabel+4024)
#define CT_v1570	((void*)startLabel+4156)
#define CT_v1579	((void*)startLabel+4472)
#define FN_Data_46Fixed_46Prelude_46245_46i	((void*)startLabel+4536)
#define CT_v1583	((void*)startLabel+4588)
#define F0_Data_46Fixed_46Prelude_46245_46i	((void*)startLabel+4596)
#define FN_Data_46Fixed_46withType	((void*)startLabel+4628)
#define CT_v1586	((void*)startLabel+4652)
#define F0_Data_46Fixed_46withType	((void*)startLabel+4660)
#define FN_Data_46Fixed_46withResolution	((void*)startLabel+4696)
#define CT_v1592	((void*)startLabel+4808)
#define F0_Data_46Fixed_46withResolution	((void*)startLabel+4816)
#define CT_v1597	((void*)startLabel+4936)
#define FN_LAMBDA1374	((void*)startLabel+4984)
#define CT_v1603	((void*)startLabel+5100)
#define F0_LAMBDA1374	((void*)startLabel+5108)
#define CT_v1609	((void*)startLabel+5272)
#define CT_v1615	((void*)startLabel+5436)
#define CT_v1621	((void*)startLabel+5612)
#define CT_v1626	((void*)startLabel+5744)
#define FN_LAMBDA1375	((void*)startLabel+5792)
#define CT_v1630	((void*)startLabel+5844)
#define F0_LAMBDA1375	((void*)startLabel+5852)
#define CT_v1635	((void*)startLabel+5964)
#define CT_v1639	((void*)startLabel+6064)
#define CT_v1643	((void*)startLabel+6160)
#define CT_v1649	((void*)startLabel+6316)
#define CT_v1653	((void*)startLabel+6420)
#define CT_v1657	((void*)startLabel+6516)
#define CT_v1662	((void*)startLabel+6640)
#define CT_v1667	((void*)startLabel+6772)
#define CT_v1672	((void*)startLabel+6904)
#define CT_v1677	((void*)startLabel+7028)
#define CT_v1681	((void*)startLabel+7128)
#define CT_v1685	((void*)startLabel+7228)
#define CT_v1689	((void*)startLabel+7328)
#define CT_v1693	((void*)startLabel+7420)
#define CT_v1698	((void*)startLabel+7544)
#define FN_LAMBDA1376	((void*)startLabel+7588)
#define CT_v1702	((void*)startLabel+7632)
#define CF_LAMBDA1376	((void*)startLabel+7640)
#define CT_v1709	((void*)startLabel+7840)
#define CT_v1719	((void*)startLabel+8180)
#define FN_Data_46Fixed_46Prelude_46185_46f	((void*)startLabel+8256)
#define CT_v1723	((void*)startLabel+8308)
#define F0_Data_46Fixed_46Prelude_46185_46f	((void*)startLabel+8316)
#define CT_v1734	((void*)startLabel+8712)
#define FN_Data_46Fixed_46Prelude_46182_46f	((void*)startLabel+8788)
#define CT_v1738	((void*)startLabel+8840)
#define F0_Data_46Fixed_46Prelude_46182_46f	((void*)startLabel+8848)
#define CT_v1742	((void*)startLabel+8936)
#define CT_v1746	((void*)startLabel+9032)
#define CT_v1750	((void*)startLabel+9128)
#define CT_v1754	((void*)startLabel+9228)
#define CT_v1758	((void*)startLabel+9328)
#define CT_v1762	((void*)startLabel+9428)
#define CT_v1766	((void*)startLabel+9528)
#define CT_v1770	((void*)startLabel+9628)
#define CT_v1774	((void*)startLabel+9724)
#define CT_v1778	((void*)startLabel+9836)
#define CT_v1782	((void*)startLabel+9960)
#define CT_v1785	((void*)startLabel+10048)
#define CT_v1789	((void*)startLabel+10164)
#define CT_v1801	((void*)startLabel+10552)
#define CT_v1807	((void*)startLabel+10752)
#define CT_v1815	((void*)startLabel+10992)
#define CT_v1826	((void*)startLabel+11336)
#define CT_v1834	((void*)startLabel+11592)
#define CT_v1838	((void*)startLabel+11712)
#define CT_v1842	((void*)startLabel+11820)
#define ST_v1432	((void*)startLabel+11852)
#define ST_v1529	((void*)startLabel+11853)
#define ST_v1404	((void*)startLabel+11856)
#define ST_v1840	((void*)startLabel+11868)
#define ST_v1406	((void*)startLabel+11908)
#define ST_v1836	((void*)startLabel+11960)
#define ST_v1409	((void*)startLabel+12000)
#define ST_v1695	((void*)startLabel+12052)
#define PP_LAMBDA1376	((void*)startLabel+12076)
#define PC_LAMBDA1376	((void*)startLabel+12076)
#define ST_v1700	((void*)startLabel+12076)
#define PP_Data_46Fixed_46chopZeros	((void*)startLabel+12106)
#define PC_Data_46Fixed_46chopZeros	((void*)startLabel+12106)
#define ST_v1443	((void*)startLabel+12106)
#define PP_LAMBDA1368	((void*)startLabel+12127)
#define PC_LAMBDA1368	((void*)startLabel+12127)
#define ST_v1452	((void*)startLabel+12127)
#define ST_v1704	((void*)startLabel+12164)
#define ST_v1725	((void*)startLabel+12180)
#define PP_Data_46Fixed_46Prelude_46182_46f	((void*)startLabel+12199)
#define PC_Data_46Fixed_46Prelude_46182_46f	((void*)startLabel+12199)
#define ST_v1736	((void*)startLabel+12199)
#define PP_Data_46Fixed_46fixedResolution	((void*)startLabel+12229)
#define PC_Data_46Fixed_46fixedResolution	((void*)startLabel+12229)
#define ST_v1412	((void*)startLabel+12229)
#define PP_Data_46Fixed_46Prelude_46188_46uf	((void*)startLabel+12256)
#define PC_Data_46Fixed_46Prelude_46188_46uf	((void*)startLabel+12256)
#define ST_v1418	((void*)startLabel+12256)
#define ST_v1711	((void*)startLabel+12296)
#define PP_Data_46Fixed_46Prelude_46185_46f	((void*)startLabel+12312)
#define PC_Data_46Fixed_46Prelude_46185_46f	((void*)startLabel+12312)
#define ST_v1721	((void*)startLabel+12312)
#define ST_v1784	((void*)startLabel+12340)
#define ST_v1488	((void*)startLabel+12364)
#define PP_LAMBDA1371	((void*)startLabel+12385)
#define PC_LAMBDA1371	((void*)startLabel+12385)
#define ST_v1528	((void*)startLabel+12385)
#define PP_LAMBDA1372	((void*)startLabel+12420)
#define PC_LAMBDA1372	((void*)startLabel+12420)
#define ST_v1525	((void*)startLabel+12420)
#define PP_LAMBDA1373	((void*)startLabel+12448)
#define PC_LAMBDA1373	((void*)startLabel+12448)
#define ST_v1522	((void*)startLabel+12448)
#define PP_Data_46Fixed_46Prelude_46271_46digits	((void*)startLabel+12476)
#define PC_Data_46Fixed_46Prelude_46271_46digits	((void*)startLabel+12476)
#define ST_v1516	((void*)startLabel+12476)
#define PP_Data_46Fixed_46Prelude_46272_46maxnum	((void*)startLabel+12510)
#define PC_Data_46Fixed_46Prelude_46272_46maxnum	((void*)startLabel+12510)
#define ST_v1509	((void*)startLabel+12510)
#define PP_Data_46Fixed_46showIntegerZeros	((void*)startLabel+12544)
#define PC_Data_46Fixed_46showIntegerZeros	((void*)startLabel+12544)
#define ST_v1463	((void*)startLabel+12544)
#define PP_LAMBDA1369	((void*)startLabel+12572)
#define PC_LAMBDA1369	((void*)startLabel+12572)
#define ST_v1481	((void*)startLabel+12572)
#define PP_LAMBDA1370	((void*)startLabel+12614)
#define PC_LAMBDA1370	((void*)startLabel+12614)
#define ST_v1477	((void*)startLabel+12614)
#define PP_Data_46Fixed_46withDot	((void*)startLabel+12656)
#define PC_Data_46Fixed_46withDot	((void*)startLabel+12656)
#define ST_v1425	((void*)startLabel+12656)
#define PP_LAMBDA1367	((void*)startLabel+12675)
#define PC_LAMBDA1367	((void*)startLabel+12675)
#define ST_v1431	((void*)startLabel+12675)
#define PP_Data_46Fixed_46withResolution	((void*)startLabel+12708)
#define PC_Data_46Fixed_46withResolution	((void*)startLabel+12708)
#define ST_v1588	((void*)startLabel+12708)
#define PP_Data_46Fixed_46withType	((void*)startLabel+12734)
#define PC_Data_46Fixed_46withType	((void*)startLabel+12734)
#define ST_v1585	((void*)startLabel+12734)
#define ST_v1701	((void*)startLabel+12754)
#define ST_v1787	((void*)startLabel+12804)
#define ST_v1674	((void*)startLabel+12836)
#define ST_v1669	((void*)startLabel+12876)
#define ST_v1659	((void*)startLabel+12920)
#define ST_v1664	((void*)startLabel+12968)
#define ST_v1679	((void*)startLabel+13012)
#define ST_v1687	((void*)startLabel+13052)
#define ST_v1691	((void*)startLabel+13088)
#define ST_v1683	((void*)startLabel+13124)
#define ST_v1776	((void*)startLabel+13164)
#define ST_v1772	((void*)startLabel+13192)
#define ST_v1768	((void*)startLabel+13224)
#define ST_v1809	((void*)startLabel+13256)
#define ST_v1611	((void*)startLabel+13292)
#define ST_v1594	((void*)startLabel+13332)
#define PP_LAMBDA1374	((void*)startLabel+13381)
#define PC_LAMBDA1374	((void*)startLabel+13381)
#define ST_v1599	((void*)startLabel+13381)
#define ST_v1605	((void*)startLabel+13444)
#define ST_v1791	((void*)startLabel+13488)
#define ST_v1645	((void*)startLabel+13520)
#define ST_v1655	((void*)startLabel+13552)
#define ST_v1651	((void*)startLabel+13584)
#define ST_v1637	((void*)startLabel+13616)
#define ST_v1623	((void*)startLabel+13652)
#define PP_LAMBDA1375	((void*)startLabel+13693)
#define PC_LAMBDA1375	((void*)startLabel+13693)
#define ST_v1628	((void*)startLabel+13693)
#define ST_v1641	((void*)startLabel+13748)
#define ST_v1632	((void*)startLabel+13784)
#define ST_v1780	((void*)startLabel+13820)
#define ST_v1764	((void*)startLabel+13852)
#define ST_v1744	((void*)startLabel+13884)
#define ST_v1756	((void*)startLabel+13916)
#define ST_v1760	((void*)startLabel+13948)
#define ST_v1740	((void*)startLabel+13980)
#define ST_v1752	((void*)startLabel+14020)
#define ST_v1748	((void*)startLabel+14056)
#define ST_v1803	((void*)startLabel+14092)
#define ST_v1617	((void*)startLabel+14124)
#define ST_v1817	((void*)startLabel+14168)
#define ST_v1557	((void*)startLabel+14204)
#define ST_v1552	((void*)startLabel+14248)
#define ST_v1572	((void*)startLabel+14288)
#define PP_Data_46Fixed_46Prelude_46245_46i	((void*)startLabel+14337)
#define PC_Data_46Fixed_46Prelude_46245_46i	((void*)startLabel+14337)
#define ST_v1581	((void*)startLabel+14337)
#define ST_v1562	((void*)startLabel+14400)
#define ST_v1567	((void*)startLabel+14440)
#define ST_v1828	((void*)startLabel+14484)
#define ST_v1532	((void*)startLabel+14516)
#define ST_v1542	((void*)startLabel+14552)
#define ST_v1547	((void*)startLabel+14592)
#define ST_v1537	((void*)startLabel+14632)
#define PS_v1706	((void*)startLabel+14672)
#define PS_v1705	((void*)startLabel+14684)
#define PS_v1703	((void*)startLabel+14696)
#define PS_v1708	((void*)startLabel+14708)
#define PS_v1707	((void*)startLabel+14720)
#define PS_v1732	((void*)startLabel+14732)
#define PS_v1727	((void*)startLabel+14744)
#define PS_v1731	((void*)startLabel+14756)
#define PS_v1733	((void*)startLabel+14768)
#define PS_v1729	((void*)startLabel+14780)
#define PS_v1730	((void*)startLabel+14792)
#define PS_v1724	((void*)startLabel+14804)
#define PS_v1726	((void*)startLabel+14816)
#define PS_v1728	((void*)startLabel+14828)
#define PS_v1717	((void*)startLabel+14840)
#define PS_v1716	((void*)startLabel+14852)
#define PS_v1718	((void*)startLabel+14864)
#define PS_v1713	((void*)startLabel+14876)
#define PS_v1714	((void*)startLabel+14888)
#define PS_v1710	((void*)startLabel+14900)
#define PS_v1715	((void*)startLabel+14912)
#define PS_v1712	((void*)startLabel+14924)
#define PS_v1783	((void*)startLabel+14936)
#define PS_v1414	((void*)startLabel+14948)
#define PS_v1415	((void*)startLabel+14960)
#define PS_v1411	((void*)startLabel+14972)
#define PS_v1413	((void*)startLabel+14984)
#define PS_v1584	((void*)startLabel+14996)
#define PS_v1590	((void*)startLabel+15008)
#define PS_v1589	((void*)startLabel+15020)
#define PS_v1591	((void*)startLabel+15032)
#define PS_v1587	((void*)startLabel+15044)
#define PS_v1444	((void*)startLabel+15056)
#define PS_v1442	((void*)startLabel+15068)
#define PS_v1447	((void*)startLabel+15080)
#define PS_v1446	((void*)startLabel+15092)
#define PS_v1448	((void*)startLabel+15104)
#define PS_v1449	((void*)startLabel+15116)
#define PS_v1445	((void*)startLabel+15128)
#define PS_v1465	((void*)startLabel+15140)
#define PS_v1472	((void*)startLabel+15152)
#define PS_v1471	((void*)startLabel+15164)
#define PS_v1469	((void*)startLabel+15176)
#define PS_v1462	((void*)startLabel+15188)
#define PS_v1467	((void*)startLabel+15200)
#define PS_v1470	((void*)startLabel+15212)
#define PS_v1466	((void*)startLabel+15224)
#define PS_v1468	((void*)startLabel+15236)
#define PS_v1428	((void*)startLabel+15248)
#define PS_v1424	((void*)startLabel+15260)
#define PS_v1427	((void*)startLabel+15272)
#define PS_v1493	((void*)startLabel+15284)
#define PS_v1500	((void*)startLabel+15296)
#define PS_v1494	((void*)startLabel+15308)
#define PS_v1491	((void*)startLabel+15320)
#define PS_v1495	((void*)startLabel+15332)
#define PS_v1505	((void*)startLabel+15344)
#define PS_v1506	((void*)startLabel+15356)
#define PS_v1487	((void*)startLabel+15368)
#define PS_v1504	((void*)startLabel+15380)
#define PS_v1499	((void*)startLabel+15392)
#define PS_v1502	((void*)startLabel+15404)
#define PS_v1503	((void*)startLabel+15416)
#define PS_v1489	((void*)startLabel+15428)
#define PS_v1492	((void*)startLabel+15440)
#define PS_v1496	((void*)startLabel+15452)
#define PS_v1501	((void*)startLabel+15464)
#define PS_v1490	((void*)startLabel+15476)
#define PS_v1497	((void*)startLabel+15488)
#define PS_v1498	((void*)startLabel+15500)
#define PS_v1737	((void*)startLabel+15512)
#define PS_v1735	((void*)startLabel+15524)
#define PS_v1722	((void*)startLabel+15536)
#define PS_v1720	((void*)startLabel+15548)
#define PS_v1697	((void*)startLabel+15560)
#define PS_v1694	((void*)startLabel+15572)
#define PS_v1696	((void*)startLabel+15584)
#define PS_v1417	((void*)startLabel+15596)
#define PS_v1690	((void*)startLabel+15608)
#define PS_v1692	((void*)startLabel+15620)
#define PS_v1686	((void*)startLabel+15632)
#define PS_v1688	((void*)startLabel+15644)
#define PS_v1684	((void*)startLabel+15656)
#define PS_v1682	((void*)startLabel+15668)
#define PS_v1678	((void*)startLabel+15680)
#define PS_v1680	((void*)startLabel+15692)
#define PS_v1673	((void*)startLabel+15704)
#define PS_v1676	((void*)startLabel+15716)
#define PS_v1675	((void*)startLabel+15728)
#define PS_v1668	((void*)startLabel+15740)
#define PS_v1671	((void*)startLabel+15752)
#define PS_v1670	((void*)startLabel+15764)
#define PS_v1663	((void*)startLabel+15776)
#define PS_v1666	((void*)startLabel+15788)
#define PS_v1665	((void*)startLabel+15800)
#define PS_v1658	((void*)startLabel+15812)
#define PS_v1661	((void*)startLabel+15824)
#define PS_v1660	((void*)startLabel+15836)
#define PS_v1654	((void*)startLabel+15848)
#define PS_v1656	((void*)startLabel+15860)
#define PS_v1650	((void*)startLabel+15872)
#define PS_v1652	((void*)startLabel+15884)
#define PS_v1647	((void*)startLabel+15896)
#define PS_v1644	((void*)startLabel+15908)
#define PS_v1648	((void*)startLabel+15920)
#define PS_v1646	((void*)startLabel+15932)
#define PS_v1640	((void*)startLabel+15944)
#define PS_v1642	((void*)startLabel+15956)
#define PS_v1636	((void*)startLabel+15968)
#define PS_v1638	((void*)startLabel+15980)
#define PS_v1631	((void*)startLabel+15992)
#define PS_v1634	((void*)startLabel+16004)
#define PS_v1633	((void*)startLabel+16016)
#define PS_v1625	((void*)startLabel+16028)
#define PS_v1622	((void*)startLabel+16040)
#define PS_v1624	((void*)startLabel+16052)
#define PS_v1619	((void*)startLabel+16064)
#define PS_v1616	((void*)startLabel+16076)
#define PS_v1618	((void*)startLabel+16088)
#define PS_v1620	((void*)startLabel+16100)
#define PS_v1612	((void*)startLabel+16112)
#define PS_v1610	((void*)startLabel+16124)
#define PS_v1614	((void*)startLabel+16136)
#define PS_v1613	((void*)startLabel+16148)
#define PS_v1606	((void*)startLabel+16160)
#define PS_v1604	((void*)startLabel+16172)
#define PS_v1608	((void*)startLabel+16184)
#define PS_v1607	((void*)startLabel+16196)
#define PS_v1596	((void*)startLabel+16208)
#define PS_v1593	((void*)startLabel+16220)
#define PS_v1595	((void*)startLabel+16232)
#define PS_v1574	((void*)startLabel+16244)
#define PS_v1576	((void*)startLabel+16256)
#define PS_v1578	((void*)startLabel+16268)
#define PS_v1571	((void*)startLabel+16280)
#define PS_v1573	((void*)startLabel+16292)
#define PS_v1577	((void*)startLabel+16304)
#define PS_v1575	((void*)startLabel+16316)
#define PS_v1580	((void*)startLabel+16328)
#define PS_v1582	((void*)startLabel+16340)
#define PS_v1566	((void*)startLabel+16352)
#define PS_v1568	((void*)startLabel+16364)
#define PS_v1569	((void*)startLabel+16376)
#define PS_v1561	((void*)startLabel+16388)
#define PS_v1563	((void*)startLabel+16400)
#define PS_v1564	((void*)startLabel+16412)
#define PS_v1556	((void*)startLabel+16424)
#define PS_v1558	((void*)startLabel+16436)
#define PS_v1559	((void*)startLabel+16448)
#define PS_v1551	((void*)startLabel+16460)
#define PS_v1554	((void*)startLabel+16472)
#define PS_v1553	((void*)startLabel+16484)
#define PS_v1515	((void*)startLabel+16496)
#define PS_v1519	((void*)startLabel+16508)
#define PS_v1518	((void*)startLabel+16520)
#define PS_v1517	((void*)startLabel+16532)
#define PS_v1511	((void*)startLabel+16544)
#define PS_v1513	((void*)startLabel+16556)
#define PS_v1510	((void*)startLabel+16568)
#define PS_v1512	((void*)startLabel+16580)
#define PS_v1508	((void*)startLabel+16592)
#define PS_v1533	((void*)startLabel+16604)
#define PS_v1534	((void*)startLabel+16616)
#define PS_v1531	((void*)startLabel+16628)
#define PS_v1408	((void*)startLabel+16640)
#define PS_v1405	((void*)startLabel+16652)
#define PS_v1549	((void*)startLabel+16664)
#define PS_v1546	((void*)startLabel+16676)
#define PS_v1548	((void*)startLabel+16688)
#define PS_v1544	((void*)startLabel+16700)
#define PS_v1541	((void*)startLabel+16712)
#define PS_v1543	((void*)startLabel+16724)
#define PS_v1539	((void*)startLabel+16736)
#define PS_v1536	((void*)startLabel+16748)
#define PS_v1538	((void*)startLabel+16760)
#define PS_v1767	((void*)startLabel+16772)
#define PS_v1769	((void*)startLabel+16784)
#define PS_v1773	((void*)startLabel+16796)
#define PS_v1771	((void*)startLabel+16808)
#define PS_v1743	((void*)startLabel+16820)
#define PS_v1745	((void*)startLabel+16832)
#define PS_v1739	((void*)startLabel+16844)
#define PS_v1741	((void*)startLabel+16856)
#define PS_v1765	((void*)startLabel+16868)
#define PS_v1763	((void*)startLabel+16880)
#define PS_v1761	((void*)startLabel+16892)
#define PS_v1759	((void*)startLabel+16904)
#define PS_v1757	((void*)startLabel+16916)
#define PS_v1755	((void*)startLabel+16928)
#define PS_v1753	((void*)startLabel+16940)
#define PS_v1751	((void*)startLabel+16952)
#define PS_v1749	((void*)startLabel+16964)
#define PS_v1747	((void*)startLabel+16976)
#define PS_v1832	((void*)startLabel+16988)
#define PS_v1829	((void*)startLabel+17000)
#define PS_v1831	((void*)startLabel+17012)
#define PS_v1830	((void*)startLabel+17024)
#define PS_v1827	((void*)startLabel+17036)
#define PS_v1833	((void*)startLabel+17048)
#define PS_v1794	((void*)startLabel+17060)
#define PS_v1795	((void*)startLabel+17072)
#define PS_v1793	((void*)startLabel+17084)
#define PS_v1796	((void*)startLabel+17096)
#define PS_v1799	((void*)startLabel+17108)
#define PS_v1797	((void*)startLabel+17120)
#define PS_v1798	((void*)startLabel+17132)
#define PS_v1792	((void*)startLabel+17144)
#define PS_v1790	((void*)startLabel+17156)
#define PS_v1800	((void*)startLabel+17168)
#define PS_v1779	((void*)startLabel+17180)
#define PS_v1781	((void*)startLabel+17192)
#define PS_v1775	((void*)startLabel+17204)
#define PS_v1777	((void*)startLabel+17216)
#define PS_v1788	((void*)startLabel+17228)
#define PS_v1786	((void*)startLabel+17240)
#define PS_v1805	((void*)startLabel+17252)
#define PS_v1804	((void*)startLabel+17264)
#define PS_v1802	((void*)startLabel+17276)
#define PS_v1806	((void*)startLabel+17288)
#define PS_v1811	((void*)startLabel+17300)
#define PS_v1813	((void*)startLabel+17312)
#define PS_v1812	((void*)startLabel+17324)
#define PS_v1810	((void*)startLabel+17336)
#define PS_v1808	((void*)startLabel+17348)
#define PS_v1814	((void*)startLabel+17360)
#define PS_v1823	((void*)startLabel+17372)
#define PS_v1821	((void*)startLabel+17384)
#define PS_v1820	((void*)startLabel+17396)
#define PS_v1822	((void*)startLabel+17408)
#define PS_v1824	((void*)startLabel+17420)
#define PS_v1818	((void*)startLabel+17432)
#define PS_v1819	((void*)startLabel+17444)
#define PS_v1816	((void*)startLabel+17456)
#define PS_v1825	((void*)startLabel+17468)
#define PS_v1837	((void*)startLabel+17480)
#define PS_v1835	((void*)startLabel+17492)
#define PS_v1841	((void*)startLabel+17504)
#define PS_v1839	((void*)startLabel+17516)
#define PS_v1430	((void*)startLabel+17528)
#define PS_v1451	((void*)startLabel+17540)
#define PS_v1480	((void*)startLabel+17552)
#define PS_v1478	((void*)startLabel+17564)
#define PS_v1476	((void*)startLabel+17576)
#define PS_v1527	((void*)startLabel+17588)
#define PS_v1524	((void*)startLabel+17600)
#define PS_v1521	((void*)startLabel+17612)
#define PS_v1602	((void*)startLabel+17624)
#define PS_v1601	((void*)startLabel+17636)
#define PS_v1600	((void*)startLabel+17648)
#define PS_v1598	((void*)startLabel+17660)
#define PS_v1629	((void*)startLabel+17672)
#define PS_v1627	((void*)startLabel+17684)
#define PS_v1699	((void*)startLabel+17696)
extern Node FN_NHC_46Internal_46_95apply1[];
extern Node FN_Data_46Fixed_46resolution[];
extern Node CF_Prelude_46undefined[];
extern Node FN_NHC_46Internal_46_95eqInteger[];
extern Node FN_Prelude_46Integral_46Prelude_46Integer_46mod[];
extern Node FN_Prelude_46Eq_46Prelude_46Integer_46_61_61[];
extern Node FN_Prelude_46Integral_46Prelude_46Integer_46div[];
extern Node FN_Prelude_46Show_46Prelude_46Integer_46show[];
extern Node FN_Prelude_46length[];
extern Node FN_Prelude_46Num_46Prelude_46Int_46_45[];
extern Node FN_Prelude_46replicate[];
extern Node FN_Prelude_46_43_43[];
extern Node FN_Prelude_46Ord_46Prelude_46Integer_46_60[];
extern Node FN_Prelude_46asTypeOf[];
extern Node FN_Prelude_46Num_46Prelude_46Integer_46negate[];
extern Node FN_NHC_46Internal_46_95apply2[];
extern Node FN_Prelude_46Integral_46Prelude_46Integer_46divMod[];
extern Node CF_Prelude_46Num_46Prelude_46Integer[];
extern Node FN_Prelude_46Num_46Prelude_46Integer_46_42[];
extern Node CF_Prelude_46Integral_46Prelude_46Int[];
extern Node CF_Prelude_46Integral_46Prelude_46Integer[];
extern Node FN_Prelude_46fromInteger[];
extern Node FN_Prelude_46_94[];
extern Node FN_Prelude_46Num_46Prelude_46Double_46fromInteger[];
extern Node FN_Prelude_46Floating_46Prelude_46Double_46logBase[];
extern Node FN_Prelude_46RealFrac_46Prelude_46Double_46ceiling[];
extern Node FN_Prelude_46Show_46Data_46Fixed_46Fixed[];
extern Node FN_Prelude_46_95_46showsType[];
extern Node FN_Prelude_46_95_46showList[];
extern Node FN_Prelude_46_95_46showsPrec[];
extern Node FN_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational[];
extern Node FN_Prelude_46RealFrac_46Ratio_46Ratio_46floor[];
extern Node FN_Prelude_46RealFrac_46Ratio_46Ratio_46ceiling[];
extern Node FN_Prelude_46RealFrac_46Ratio_46Ratio_46round[];
extern Node FN_Prelude_46RealFrac_46Ratio_46Ratio_46truncate[];
extern Node FN_Prelude_46Num_46Data_46Fixed_46Fixed[];
extern Node FN_Prelude_46fromIntegral[];
extern Node FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_45[];
extern Node FN_Prelude_46_46[];
extern Node FN_Prelude_46Real_46Prelude_46Integer_46toRational[];
extern Node FN_Prelude_46Num_46Ratio_46Ratio_46_42[];
extern Node FN_Prelude_46Fractional_46Ratio_46Ratio_46_47[];
extern Node FN_Prelude_46Num_46Prelude_46Integer_46signum[];
extern Node FN_Prelude_46Num_46Prelude_46Integer_46abs[];
extern Node FN_Prelude_46Num_46Prelude_46Integer_46_45[];
extern Node FN_Prelude_46Num_46Prelude_46Integer_46_43[];
extern Node FN_Prelude_46Enum_46Prelude_46Integer_46enumFromThenTo[];
extern Node FN_Prelude_46Functor_46Prelude_46_91_93_46fmap[];
extern Node F0_NHC_46Internal_46_95id[];
extern Node FN_Prelude_46Enum_46Prelude_46Integer_46enumFromTo[];
extern Node FN_Prelude_46Enum_46Prelude_46Integer_46enumFromThen[];
extern Node FN_Prelude_46Enum_46Prelude_46Integer_46enumFrom[];
extern Node FN_Prelude_46Enum_46Prelude_46Integer_46fromEnum[];
extern Node F0_Prelude_46Enum_46Prelude_46Integer_46toEnum[];
extern Node FN_Prelude_46Enum_46Prelude_46Integer_46pred[];
extern Node FN_Prelude_46Enum_46Prelude_46Integer_46succ[];
extern Node FN_NHC_46Internal_46_95noMethodError[];
extern Node FN_Prelude_46toRational[];
extern Node FN_Prelude_46Real_46Prelude_46Num[];
extern Node FN_Prelude_46_42[];
extern Node FN_Prelude_46_45[];
extern Node FN_Prelude_46Ord_46Prelude_46Integer_46compare[];
extern Node FN_Prelude_46Ord_46Prelude_46Integer_46_60_61[];
extern Node FN_Prelude_46_95_46min[];
extern Node CF_Prelude_46Ord_46Data_46Fixed_46Fixed[];
extern Node FN_Prelude_46_95_46max[];
extern Node FN_Prelude_46_95_46_62[];
extern Node FN_Prelude_46_95_46_62_61[];
extern Node FN_Prelude_46_95_46_60[];
extern Node FN_Prelude_46_95_46_47_61[];
extern Node CF_Prelude_46Eq_46Data_46Fixed_46Fixed[];
extern Node PC_NHC_46Internal_46_95apply1[];
extern Node PC_Prelude_46toRational[];
extern Node PC_Prelude_46RealFrac_46Ratio_46Ratio_46floor[];
extern Node PC_Prelude_46Fractional_46Ratio_46Ratio_46_47[];
extern Node PC_NHC_46Internal_46_95apply2[];
extern Node PC_Prelude_46fromIntegral[];
extern Node PC_Prelude_462[];
extern Node PC_Prelude_46_45[];
extern Node PC_Prelude_46_42[];
extern Node PC_Prelude_46Real_46Prelude_46Num[];
extern Node PC_Prelude_46fromInteger[];
extern Node PC_Prelude_46_46[];
extern Node PC_NHC_46Internal_46_95eqInteger[];
extern Node PC_Prelude_46Eq_46Prelude_46Integer_46_61_61[];
extern Node PC_Prelude_46Integral_46Prelude_46Integer_46mod[];
extern Node PC_Prelude_46Integral_46Prelude_46Integer_46div[];
extern Node PC_Prelude_46Show_46Prelude_46Integer_46show[];
extern Node PC_Prelude_46_43_43[];
extern Node PC_Prelude_46replicate[];
extern Node PC_Prelude_46length[];
extern Node PC_Prelude_46Num_46Prelude_46Int_46_45[];
extern Node PC_Prelude_46_58[];
extern Node PC_Prelude_46asTypeOf[];
extern Node PC_Prelude_46Ord_46Prelude_46Integer_46_60[];
extern Node PC_Prelude_46Num_46Prelude_46Integer_46negate[];
extern Node PC_Prelude_46Integral_46Prelude_46Integer_46divMod[];
extern Node PC_Prelude_46Num_46Prelude_46Integer_46_42[];
extern Node PC_NHC_46Internal_46_95noMethodError[];
extern Node PC_Prelude_46Enum_46Prelude_46Integer_46succ[];
extern Node PC_Prelude_46Enum_46Prelude_46Integer_46pred[];
extern Node PC_Prelude_46Enum_46Prelude_46Integer_46fromEnum[];
extern Node PC_Prelude_46Functor_46Prelude_46_91_93_46fmap[];
extern Node PC_Prelude_46Enum_46Prelude_46Integer_46enumFrom[];
extern Node PC_Prelude_46Enum_46Prelude_46Integer_46enumFromThen[];
extern Node PC_Prelude_46Enum_46Prelude_46Integer_46enumFromTo[];
extern Node PC_Prelude_46Enum_46Prelude_46Integer_46enumFromThenTo[];
extern Node PC_Prelude_46Num_46Prelude_46Integer_46_43[];
extern Node PC_Prelude_46Num_46Prelude_46Integer_46_45[];
extern Node PC_Prelude_46Num_46Prelude_46Integer_46abs[];
extern Node PC_Prelude_46Num_46Prelude_46Integer_46signum[];
extern Node PC_Prelude_46Real_46Prelude_46Integer_46toRational[];
extern Node PC_Prelude_46RealFrac_46Ratio_46Ratio_46truncate[];
extern Node PC_Prelude_46RealFrac_46Ratio_46Ratio_46round[];
extern Node PC_Prelude_46RealFrac_46Ratio_46Ratio_46ceiling[];
extern Node PC_Prelude_46RealFrac_46Prelude_46Double_46ceiling[];
extern Node PC_Prelude_46Floating_46Prelude_46Double_46logBase[];
extern Node PC_Prelude_46Num_46Prelude_46Double_46fromInteger[];
extern Node PC_Prelude_46_94[];
extern Node PC_Prelude_46False[];
extern Node PC_Prelude_46_95_46showsPrec[];
extern Node PC_Prelude_46_95_46showList[];
extern Node PC_Prelude_46_95_46showsType[];
extern Node PC_Prelude_46_95_46_47_61[];
extern Node PC_Prelude_46Ord_46Prelude_46Integer_46_60_61[];
extern Node PC_Prelude_46Ord_46Prelude_46Integer_46compare[];
extern Node PC_Prelude_46_95_46_60[];
extern Node PC_Prelude_46_95_46_62_61[];
extern Node PC_Prelude_46_95_46_62[];
extern Node PC_Prelude_46_95_46max[];
extern Node PC_Prelude_46_95_46min[];
extern Node PC_Prelude_464[];
extern Node PC_Prelude_469[];
extern Node PC_Prelude_468[];
extern Node PC_Prelude_463[];
extern Node PC_Prelude_467[];
extern Node PC_Prelude_461[];
extern Node PC_Prelude_46Num_46Ratio_46Ratio_46_42[];

static Node startLabel[] = {
  42
,};
Node PP_Data_46Fixed_46MkFixed[] = {
 };
Node PC_Data_46Fixed_46MkFixed[] = {
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,77)
, bytes2word(107,70,105,120)
, bytes2word(101,100,0,0)
,	/* PS_Data_46Fixed_46MkFixed: (byte 0) */
  useLabel(PP_Data_46Fixed_46MkFixed)
, useLabel(PP_Data_46Fixed_46MkFixed)
, useLabel(PC_Data_46Fixed_46MkFixed)
,};
Node PP_Data_46Fixed_46E6[] = {
 };
Node PC_Data_46Fixed_46E6[] = {
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,69)
, bytes2word(54,0,0,0)
,	/* PS_Data_46Fixed_46E6: (byte 0) */
  useLabel(PP_Data_46Fixed_46E6)
, useLabel(PP_Data_46Fixed_46E6)
, useLabel(PC_Data_46Fixed_46E6)
,	/* C0_Data_46Fixed_46E6: (byte 0) */
  CONSTR(0,0,0)
, useLabel(PS_Data_46Fixed_46E6)
, 0
, 0
, 0
,};
Node PP_Data_46Fixed_46E12[] = {
 };
Node PC_Data_46Fixed_46E12[] = {
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,69)
, bytes2word(49,50,0,0)
,	/* PS_Data_46Fixed_46E12: (byte 0) */
  useLabel(PP_Data_46Fixed_46E12)
, useLabel(PP_Data_46Fixed_46E12)
, useLabel(PC_Data_46Fixed_46E12)
,	/* C0_Data_46Fixed_46E12: (byte 0) */
  CONSTR(0,0,0)
, useLabel(PS_Data_46Fixed_46E12)
, 0
, 0
, 0
, bytes2word(1,0,0,1)
, useLabel(CT_v1407)
,};
Node FN_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12_46resolution[] = {
  bytes2word(ZAP_ARG_I1,NEEDSTACK_I16,PUSH_CADR_N1,9)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTRW(2,0)
, 0
, 0
, 0
, 0
, -727379968
, 232
, 1450009
, useLabel(ST_v1406)
,	/* CT_v1407: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12_46resolution[] = {
  CAPTAG(useLabel(FN_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12_46resolution),1)
, useLabel(PS_v1405)
, 0
, 0
, 0
, bytes2word(1,0,0,1)
, useLabel(CT_v1410)
,};
Node FN_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6_46resolution[] = {
  bytes2word(ZAP_ARG_I1,NEEDSTACK_I16,PUSH_CADR_N1,8)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, 0
, 0
, 0
, 0
, 1000000
, 1370009
, useLabel(ST_v1409)
,	/* CT_v1410: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6_46resolution[] = {
  CAPTAG(useLabel(FN_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6_46resolution),1)
, useLabel(PS_v1408)
, 0
, 0
, 0
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1416)
,	/* FN_Data_46Fixed_46fixedResolution: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_CVAL_N1)
, bytes2word(12,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_OFF_N1,10,HEAP_ARG,2)
, bytes2word(PUSH_P1,0,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1,2)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,1)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1415)
, 0
, 0
, 0
, 0
, useLabel(PS_v1414)
, 0
, 0
, 0
, 0
, useLabel(PS_v1413)
, 0
, 0
, 0
, 0
, 560001
, useLabel(ST_v1412)
,	/* CT_v1416: (byte 0) */
  HW(3,2)
, 0
,	/* F0_Data_46Fixed_46fixedResolution: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46fixedResolution),2)
, useLabel(PS_v1411)
, 0
, 0
, 0
, CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46188_46uf),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Data_46Fixed_46resolution))
, bytes2word(1,0,0,1)
, useLabel(CT_v1419)
,	/* FN_Data_46Fixed_46Prelude_46188_46uf: (byte 0) */
  bytes2word(ZAP_ARG_I1,NEEDSTACK_I16,PUSH_CVAL_P1,7)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 580009
, useLabel(ST_v1418)
,	/* CT_v1419: (byte 0) */
  HW(1,1)
, 0
,	/* F0_Data_46Fixed_46Prelude_46188_46uf: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46188_46uf),1)
, useLabel(PS_v1417)
, 0
, 0
, 0
, useLabel(CF_Prelude_46undefined)
, bytes2word(1,0,0,1)
, useLabel(CT_v1429)
,	/* FN_Data_46Fixed_46withDot: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(8),BOT(8))
,	/* v1426: (byte 2) */
  bytes2word(TOP(4),BOT(4),POP_I1,JUMP)
,	/* v1423: (byte 2) */
  bytes2word(12,0,POP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_CVAL_N1,7)
,	/* v1420: (byte 4) */
  bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,RETURN_EVAL)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,12,HEAP_CVAL_N1)
, bytes2word(17,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_CHAR_P1,46,HEAP_ARG,1)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1428)
, 0
, 0
, 0
, 0
, CONSTR(1,2,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1427)
, 0
, 0
, 0
, 0
, 1150001
, useLabel(ST_v1425)
,	/* CT_v1429: (byte 0) */
  HW(1,1)
, 0
,	/* F0_Data_46Fixed_46withDot: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46withDot),1)
, useLabel(PS_v1424)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_LAMBDA1367))
, bytes2word(0,0,0,0)
, useLabel(CT_v1433)
,	/* FN_LAMBDA1367: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,8,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, 0
, 0
, 0
, 0
, useLabel(ST_v1432)
, 1150014
, useLabel(ST_v1431)
,	/* CT_v1433: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA1367: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA1367))
, useLabel(PS_v1430)
, 0
, 0
, 0
, bytes2word(1,0,0,1)
, useLabel(CT_v1450)
,	/* FN_Data_46Fixed_46chopZeros: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,HEAP_CADR_N1)
, bytes2word(12,EVAL,NEEDHEAP_I32,JUMPFALSE)
, bytes2word(11,0,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,17,HEAP_CREATE)
,	/* v1434: (byte 3) */
  bytes2word(HEAP_SPACE,HEAP_SPACE,RETURN_EVAL,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_N1,22,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(HEAP_CADR_N1,28,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(10,HEAP_CVAL_N1,33,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,12)
, bytes2word(HEAP_CADR_N1,12,EVAL,NEEDHEAP_I32)
, bytes2word(JUMPFALSE,24,0,HEAP_CVAL_P1)
, bytes2word(11,HEAP_CVAL_N1,38,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(HEAP_CADR_N1,28,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(12,HEAP_CVAL_N1,43,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,12)
,	/* v1438: (byte 1) */
  bytes2word(RETURN_EVAL,PUSH_HEAP,HEAP_CVAL_P1,13)
, bytes2word(HEAP_CVAL_N1,48,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1449)
, 0
, 0
, 0
, 0
, useLabel(PS_v1442)
, 0
, 0
, 0
, 0
, useLabel(PS_v1448)
, 0
, 0
, 0
, 0
, useLabel(PS_v1447)
, 0
, 0
, 0
, 0
, CONSTRW(1,0)
, 0
, 0
, 0
, 0
, 10
, useLabel(PS_v1446)
, 0
, 0
, 0
, 0
, useLabel(PS_v1445)
, 0
, 0
, 0
, 0
, CONSTRW(0,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1444)
, 0
, 0
, 0
, 0
, 1030001
, useLabel(ST_v1443)
,	/* CT_v1450: (byte 0) */
  HW(7,1)
, 0
,	/* F0_Data_46Fixed_46chopZeros: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46chopZeros),1)
, useLabel(PS_v1442)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_NHC_46Internal_46_95eqInteger))
, VAPTAG(useLabel(FN_LAMBDA1368))
, VAPTAG(useLabel(FN_Prelude_46Integral_46Prelude_46Integer_46mod))
, VAPTAG(useLabel(FN_Prelude_46Eq_46Prelude_46Integer_46_61_61))
, VAPTAG(useLabel(FN_Prelude_46Integral_46Prelude_46Integer_46div))
, VAPTAG(useLabel(FN_Data_46Fixed_46chopZeros))
, VAPTAG(useLabel(FN_Prelude_46Show_46Prelude_46Integer_46show))
, bytes2word(0,0,0,0)
, useLabel(CT_v1453)
,	/* FN_LAMBDA1368: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,8,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, 0
, 0
, 0
, 0
, useLabel(ST_v1432)
, 1030015
, useLabel(ST_v1452)
,	/* CT_v1453: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA1368: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA1368))
, useLabel(PS_v1451)
, 0
, 0
, 0
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1473)
,	/* FN_Data_46Fixed_46showIntegerZeros: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I1,EVAL,NEEDHEAP_P1)
, bytes2word(41,TABLESWITCH,2,NOP)
,	/* v1464: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v1457: (byte 4) */
  bytes2word(POP_I1,JUMP,30,0)
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,3,HEAP_CADR_N1)
, bytes2word(12,EVAL,NEEDHEAP_P1,41)
, bytes2word(JUMPFALSE,11,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,17)
,	/* v1454: (byte 4) */
  bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,RETURN_EVAL)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_CVAL_N1)
, bytes2word(22,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,3,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(10,HEAP_CVAL_N1,27,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG_ARG,1)
, bytes2word(3,HEAP_I1,HEAP_CVAL_P1,11)
, bytes2word(HEAP_CVAL_N1,32,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_I1,HEAP_CVAL_P1,12)
, bytes2word(HEAP_CVAL_N1,37,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(12,HEAP_CVAL_P1,13,HEAP_CVAL_N1)
, bytes2word(42,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_OFF_N1,12,HEAP_CHAR_P1,48)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,14,HEAP_CVAL_N1)
, bytes2word(47,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_OFF_N1,12,HEAP_I1,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1472)
, 0
, 0
, 0
, 0
, useLabel(PS_v1471)
, 0
, 0
, 0
, 0
, useLabel(PS_v1470)
, 0
, 0
, 0
, 0
, useLabel(PS_v1469)
, 0
, 0
, 0
, 0
, useLabel(PS_v1468)
, 0
, 0
, 0
, 0
, useLabel(PS_v1467)
, 0
, 0
, 0
, 0
, useLabel(PS_v1466)
, 0
, 0
, 0
, 0
, CONSTRW(0,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1465)
, 0
, 0
, 0
, 0
, 1090001
, useLabel(ST_v1463)
,	/* CT_v1473: (byte 0) */
  HW(8,3)
, 0
,	/* F0_Data_46Fixed_46showIntegerZeros: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46showIntegerZeros),3)
, useLabel(PS_v1462)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_NHC_46Internal_46_95eqInteger))
, VAPTAG(useLabel(FN_LAMBDA1369))
, VAPTAG(useLabel(FN_Prelude_46Show_46Prelude_46Integer_46show))
, VAPTAG(useLabel(FN_LAMBDA1370))
, VAPTAG(useLabel(FN_Prelude_46length))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Prelude_46replicate))
, VAPTAG(useLabel(FN_Prelude_46_43_43))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1479)
,	/* FN_LAMBDA1370: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(JUMPFALSE,13,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_ARG)
,	/* v1474: (byte 2) */
  bytes2word(2,RETURN_EVAL,PUSH_ARG_I3,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1478)
, 0
, 0
, 0
, 0
, 1120014
, useLabel(ST_v1477)
,	/* CT_v1479: (byte 0) */
  HW(1,3)
, 0
,	/* F0_LAMBDA1370: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA1370),3)
, useLabel(PS_v1476)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Data_46Fixed_46chopZeros))
, bytes2word(0,0,0,0)
, useLabel(CT_v1482)
,	/* FN_LAMBDA1369: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,8,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, 0
, 0
, 0
, 0
, useLabel(ST_v1432)
, 1090029
, useLabel(ST_v1481)
,	/* CT_v1482: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA1369: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA1369))
, useLabel(PS_v1480)
, 0
, 0
, 0
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1507)
,};
Node FN_Data_46Fixed_46showFixed[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,3,HEAP_CADR_N1)
, bytes2word(12,EVAL,NEEDHEAP_P1,94)
, bytes2word(JUMPFALSE,63,0,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,22,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,10,HEAP_CVAL_N1)
, bytes2word(27,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,11)
, bytes2word(HEAP_CVAL_N1,32,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,16,HEAP_OFF_N1)
, bytes2word(12,HEAP_ARG,3,HEAP_CVAL_P1)
, bytes2word(12,HEAP_CVAL_N1,37,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_OFF_N1,15,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,13,HEAP_CVAL_N1,42)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
,	/* v1483: (byte 4) */
  bytes2word(37,HEAP_OFF_N1,14,RETURN_EVAL)
, bytes2word(PUSH_HEAP,HEAP_ARG,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,14,HEAP_CVAL_N1,47)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_I1)
, bytes2word(HEAP_ARG,3,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(15,HEAP_CVAL_N1,52,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,3)
, bytes2word(HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1,16)
, bytes2word(HEAP_CVAL_N1,57,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,12,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,17,HEAP_CVAL_N1,62)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(18,HEAP_CVAL_P1,18,HEAP_CVAL_N1)
, bytes2word(67,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_P1,3,HEAP_CVAL_P1,19)
, bytes2word(HEAP_CVAL_N1,72,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,11,HEAP_CVAL_P1)
, bytes2word(20,HEAP_CVAL_P1,21,HEAP_CVAL_N1)
, bytes2word(77,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_P1,0,HEAP_OFF_N1,13)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,22,HEAP_CVAL_N1)
, bytes2word(82,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_OFF_N1,12,HEAP_P1,4)
, bytes2word(HEAP_CVAL_P1,23,HEAP_CVAL_N1,87)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_I2)
, bytes2word(HEAP_CVAL_P1,24,HEAP_CVAL_N1,92)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_P1)
, bytes2word(4,HEAP_CVAL_P1,19,HEAP_CVAL_N1)
, bytes2word(72,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_OFF_N1,11,HEAP_CVAL_P1,25)
, bytes2word(HEAP_CVAL_P1,26,HEAP_CVAL_N1,97)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_ARG)
, bytes2word(2,HEAP_OFF_N1,13,HEAP_P1)
, bytes2word(0,HEAP_CVAL_P1,27,HEAP_CVAL_N1)
, bytes2word(102,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_OFF_N1,13,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(13,HEAP_CVAL_N1,42,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,38)
, bytes2word(HEAP_OFF_N1,12,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v1506)
, 0
, 0
, 0
, 0
, useLabel(PS_v1505)
, 0
, 0
, 0
, 0
, useLabel(PS_v1504)
, 0
, 0
, 0
, 0
, useLabel(PS_v1503)
, 0
, 0
, 0
, 0
, useLabel(PS_v1502)
, 0
, 0
, 0
, 0
, useLabel(PS_v1501)
, 0
, 0
, 0
, 0
, useLabel(PS_v1500)
, 0
, 0
, 0
, 0
, useLabel(PS_v1499)
, 0
, 0
, 0
, 0
, useLabel(PS_v1498)
, 0
, 0
, 0
, 0
, useLabel(PS_v1497)
, 0
, 0
, 0
, 0
, useLabel(PS_v1496)
, 0
, 0
, 0
, 0
, useLabel(PS_v1495)
, 0
, 0
, 0
, 0
, useLabel(PS_v1494)
, 0
, 0
, 0
, 0
, useLabel(PS_v1487)
, 0
, 0
, 0
, 0
, useLabel(PS_v1493)
, 0
, 0
, 0
, 0
, useLabel(PS_v1492)
, 0
, 0
, 0
, 0
, useLabel(PS_v1491)
, 0
, 0
, 0
, 0
, useLabel(PS_v1490)
, 0
, 0
, 0
, 0
, CONSTRW(0,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1489)
, 0
, 0
, 0
, 0
, 1200001
, useLabel(ST_v1488)
,	/* CT_v1507: (byte 0) */
  HW(21,3)
, 0
,};
Node F0_Data_46Fixed_46showFixed[] = {
  CAPTAG(useLabel(FN_Data_46Fixed_46showFixed),3)
, useLabel(PS_v1487)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Integer_46_60))
, VAPTAG(useLabel(FN_LAMBDA1371))
, VAPTAG(useLabel(FN_Prelude_46asTypeOf))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46negate))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Data_46Fixed_46showFixed))
, VAPTAG(useLabel(FN_Prelude_46_43_43))
, VAPTAG(useLabel(FN_Data_46Fixed_46fixedResolution))
, VAPTAG(useLabel(FN_Prelude_46Integral_46Prelude_46Integer_46divMod))
, VAPTAG(useLabel(FN_LAMBDA1372))
, VAPTAG(useLabel(FN_LAMBDA1373))
, CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46272_46maxnum),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, useLabel(CF_Prelude_46Num_46Prelude_46Integer)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46_42))
, VAPTAG(useLabel(FN_Prelude_46Integral_46Prelude_46Integer_46div))
, VAPTAG(useLabel(FN_Prelude_46Show_46Prelude_46Integer_46show))
, CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46271_46digits),1)
, useLabel(CF_Prelude_46Integral_46Prelude_46Int)
, VAPTAG(useLabel(FN_Data_46Fixed_46showIntegerZeros))
, VAPTAG(useLabel(FN_Data_46Fixed_46withDot))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1514)
,	/* FN_Data_46Fixed_46Prelude_46272_46maxnum: (byte 0) */
  bytes2word(NEEDHEAP_P1,38,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_P1,8,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,2,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,11,HEAP_CADR_N1)
, bytes2word(18,HEAP_CVAL_P1,10,HEAP_CVAL_N1)
, bytes2word(23,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,11,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_P1,11)
, bytes2word(HEAP_CVAL_N1,28,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,2,HEAP_I1)
, bytes2word(HEAP_OFF_N1,27,HEAP_OFF_N1,15)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1513)
, 0
, 0
, 0
, 0
, useLabel(PS_v1512)
, 0
, 0
, 0
, 0
, CONSTRW(1,0)
, 0
, 0
, 0
, 0
, 10
, useLabel(PS_v1511)
, 0
, 0
, 0
, 0
, useLabel(PS_v1510)
, 0
, 0
, 0
, 0
, 1260009
, useLabel(ST_v1509)
,	/* CT_v1514: (byte 0) */
  HW(5,2)
, 0
,	/* F0_Data_46Fixed_46Prelude_46272_46maxnum: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46272_46maxnum),2)
, useLabel(PS_v1508)
, 0
, 0
, 0
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, VAPTAG(useLabel(FN_Prelude_46fromInteger))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46271_46digits),1)
, VAPTAG(useLabel(FN_Prelude_46_94))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1520)
,	/* FN_Data_46Fixed_46Prelude_46271_46digits: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CADR_N1,19,HEAP_OFF_N1)
, bytes2word(12,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,24,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(13,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1519)
, 0
, 0
, 0
, 0
, CONSTRW(2,0)
, 0
, 0
, 0
, 0
, 1076101120
, 0
, useLabel(PS_v1518)
, 0
, 0
, 0
, 0
, useLabel(PS_v1517)
, 0
, 0
, 0
, 0
, 1250009
, useLabel(ST_v1516)
,	/* CT_v1520: (byte 0) */
  HW(3,2)
, 0
,	/* F0_Data_46Fixed_46Prelude_46271_46digits: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46271_46digits),2)
, useLabel(PS_v1515)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Double_46fromInteger))
, VAPTAG(useLabel(FN_Prelude_46Floating_46Prelude_46Double_46logBase))
, VAPTAG(useLabel(FN_Prelude_46RealFrac_46Prelude_46Double_46ceiling))
, bytes2word(1,0,0,1)
, useLabel(CT_v1523)
,	/* FN_LAMBDA1373: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 1230012
, useLabel(ST_v1522)
,	/* CT_v1523: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA1373: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA1373),1)
, useLabel(PS_v1521)
, 0
, 0
, 0
, bytes2word(1,0,0,1)
, useLabel(CT_v1526)
,	/* FN_LAMBDA1372: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,1)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 1230010
, useLabel(ST_v1525)
,	/* CT_v1526: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA1372: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA1372),1)
, useLabel(PS_v1524)
, 0
, 0
, 0
, bytes2word(0,0,0,0)
, useLabel(CT_v1530)
,	/* FN_LAMBDA1371: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,8,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, 0
, 0
, 0
, 0
, useLabel(ST_v1529)
, 1200054
, useLabel(ST_v1528)
,	/* CT_v1530: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA1371: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA1371))
, useLabel(PS_v1527)
, 0
, 0
, 0
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1535)
,};
Node FN_Prelude_46Show_46Data_46Fixed_46Fixed_46show[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_N1,7,HEAP_CVAL_N1)
, bytes2word(12,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(17,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,11)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1534)
, 0
, 0
, 0
, 0
, useLabel(PS_v1533)
, 0
, 0
, 0
, 0
, CONSTR(0,0,0)
, 0
, 0
, 0
, 0
, 1300009
, useLabel(ST_v1532)
,	/* CT_v1535: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Fixed_46Fixed_46show[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed_46show),2)
, useLabel(PS_v1531)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Data_46Fixed_46showFixed))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1540)
,};
Node FN_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,11)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v1539)
, 0
, 0
, 0
, 0
, useLabel(PS_v1538)
, 0
, 0
, 0
, 0
, 1290031
, useLabel(ST_v1537)
,	/* CT_v1540: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType),2)
, useLabel(PS_v1536)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed))
, VAPTAG(useLabel(FN_Prelude_46_95_46showsType))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1545)
,};
Node FN_Prelude_46Show_46Data_46Fixed_46Fixed_46showList[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,11)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v1544)
, 0
, 0
, 0
, 0
, useLabel(PS_v1543)
, 0
, 0
, 0
, 0
, 1290031
, useLabel(ST_v1542)
,	/* CT_v1545: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Fixed_46Fixed_46showList[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed_46showList),2)
, useLabel(PS_v1541)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed))
, VAPTAG(useLabel(FN_Prelude_46_95_46showList))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1550)
,};
Node FN_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,11)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v1549)
, 0
, 0
, 0
, 0
, useLabel(PS_v1548)
, 0
, 0
, 0
, 0
, 1290031
, useLabel(ST_v1547)
,	/* CT_v1550: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec),3)
, useLabel(PS_v1546)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed))
, VAPTAG(useLabel(FN_Prelude_46_95_46showsPrec))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1555)
,};
Node FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1)
, bytes2word(9,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(14,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1554)
, 0
, 0
, 0
, 0
, useLabel(PS_v1553)
, 0
, 0
, 0
, 0
, 1000009
, useLabel(ST_v1552)
,	/* CT_v1555: (byte 0) */
  HW(3,3)
, 0
,};
Node F0_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor[] = {
  CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor),3)
, useLabel(PS_v1551)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational))
, VAPTAG(useLabel(FN_Prelude_46RealFrac_46Ratio_46Ratio_46floor))
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1560)
,};
Node FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1)
, bytes2word(9,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(14,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1559)
, 0
, 0
, 0
, 0
, useLabel(PS_v1558)
, 0
, 0
, 0
, 0
, 990009
, useLabel(ST_v1557)
,	/* CT_v1560: (byte 0) */
  HW(3,3)
, 0
,};
Node F0_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling[] = {
  CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling),3)
, useLabel(PS_v1556)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational))
, VAPTAG(useLabel(FN_Prelude_46RealFrac_46Ratio_46Ratio_46ceiling))
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1565)
,};
Node FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1)
, bytes2word(9,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(14,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1564)
, 0
, 0
, 0
, 0
, useLabel(PS_v1563)
, 0
, 0
, 0
, 0
, 980009
, useLabel(ST_v1562)
,	/* CT_v1565: (byte 0) */
  HW(3,3)
, 0
,};
Node F0_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round[] = {
  CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round),3)
, useLabel(PS_v1561)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational))
, VAPTAG(useLabel(FN_Prelude_46RealFrac_46Ratio_46Ratio_46round))
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1570)
,};
Node FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1)
, bytes2word(9,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(14,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1569)
, 0
, 0
, 0
, 0
, useLabel(PS_v1568)
, 0
, 0
, 0
, 0
, 970009
, useLabel(ST_v1567)
,	/* CT_v1570: (byte 0) */
  HW(3,3)
, 0
,};
Node F0_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate[] = {
  CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate),3)
, useLabel(PS_v1566)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational))
, VAPTAG(useLabel(FN_Prelude_46RealFrac_46Ratio_46Ratio_46truncate))
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1579)
,};
Node FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction[] = {
  bytes2word(NEEDHEAP_P1,68,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_P1)
, bytes2word(0,HEAP_ARG,3,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,12)
, bytes2word(HEAP_ARG,2,HEAP_CVAL_P1,10)
, bytes2word(HEAP_CVAL_N1,17,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,HEAP_CVAL_P1)
, bytes2word(11,HEAP_CVAL_N1,22,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_I1,HEAP_OFF_N1)
, bytes2word(12,HEAP_CVAL_P1,8,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_P1,0,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_P1,9,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(12,HEAP_I1,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,26,HEAP_OFF_N1)
, bytes2word(13,HEAP_CVAL_P1,12,HEAP_CVAL_N1)
, bytes2word(27,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,3,HEAP_OFF_N1)
, bytes2word(14,PUSH_HEAP,HEAP_CVAL_N1,32)
, bytes2word(HEAP_CVAL_N1,37,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,54,HEAP_OFF_N1)
, bytes2word(14,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1578)
, 0
, 0
, 0
, 0
, CONSTR(0,2,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1577)
, 0
, 0
, 0
, 0
, useLabel(PS_v1576)
, 0
, 0
, 0
, 0
, useLabel(PS_v1575)
, 0
, 0
, 0
, 0
, useLabel(PS_v1574)
, 0
, 0
, 0
, 0
, useLabel(PS_v1573)
, 0
, 0
, 0
, 0
, 950009
, useLabel(ST_v1572)
,	/* CT_v1579: (byte 0) */
  HW(6,3)
, 0
,};
Node F0_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction[] = {
  CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction),3)
, useLabel(PS_v1571)
, 0
, 0
, 0
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46245_46i),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed))
, VAPTAG(useLabel(FN_Prelude_46fromIntegral))
, VAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_45))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1583)
,	/* FN_Data_46Fixed_46Prelude_46245_46i: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG,1,3)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1582)
, 0
, 0
, 0
, 0
, 960017
, useLabel(ST_v1581)
,	/* CT_v1583: (byte 0) */
  HW(1,3)
, 0
,	/* F0_Data_46Fixed_46Prelude_46245_46i: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46245_46i),3)
, useLabel(PS_v1580)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate))
, bytes2word(1,0,0,1)
, useLabel(CT_v1586)
,	/* FN_Data_46Fixed_46withType: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_CVAL_P1,7,PUSH_ZAP_ARG_I1)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,1)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 610001
, useLabel(ST_v1585)
,	/* CT_v1586: (byte 0) */
  HW(1,1)
, 0
,	/* F0_Data_46Fixed_46withType: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46withType),1)
, useLabel(PS_v1584)
, 0
, 0
, 0
, useLabel(CF_Prelude_46undefined)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1592)
,	/* FN_Data_46Fixed_46withResolution: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(12,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,17,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,12,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1591)
, 0
, 0
, 0
, 0
, useLabel(PS_v1590)
, 0
, 0
, 0
, 0
, useLabel(PS_v1589)
, 0
, 0
, 0
, 0
, 640001
, useLabel(ST_v1588)
,	/* CT_v1592: (byte 0) */
  HW(3,2)
, 0
,	/* F0_Data_46Fixed_46withResolution: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46withResolution),2)
, useLabel(PS_v1587)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Data_46Fixed_46resolution))
, VAPTAG(useLabel(FN_Prelude_46_46))
, VAPTAG(useLabel(FN_Data_46Fixed_46withType))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1597)
,};
Node FN_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,2,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,12,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v1596)
, 0
, 0
, 0
, 0
, useLabel(PS_v1595)
, 0
, 0
, 0
, 0
, 920009
, useLabel(ST_v1594)
,	/* CT_v1597: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational[] = {
  CAPTAG(useLabel(FN_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational),2)
, useLabel(PS_v1593)
, 0
, 0
, 0
, CAPTAG(useLabel(FN_LAMBDA1374),1)
, VAPTAG(useLabel(FN_Data_46Fixed_46withResolution))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1603)
,	/* FN_LAMBDA1374: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,2,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,9,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,13,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,10,HEAP_CVAL_N1,17)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_P1,9,HEAP_OFF_N1)
, bytes2word(15,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1602)
, 0
, 0
, 0
, 0
, useLabel(PS_v1601)
, 0
, 0
, 0
, 0
, useLabel(PS_v1600)
, 0
, 0
, 0
, 0
, 920042
, useLabel(ST_v1599)
,	/* CT_v1603: (byte 0) */
  HW(4,2)
, 0
,	/* F0_LAMBDA1374: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA1374),2)
, useLabel(PS_v1598)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Real_46Prelude_46Integer_46toRational))
, VAPTAG(useLabel(FN_Prelude_46Num_46Ratio_46Ratio_46_42))
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, VAPTAG(useLabel(FN_Prelude_46RealFrac_46Ratio_46Ratio_46floor))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1609)
,};
Node FN_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_I1,HEAP_ARG,2,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_P1,0)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,12)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1608)
, 0
, 0
, 0
, 0
, useLabel(PS_v1607)
, 0
, 0
, 0
, 0
, useLabel(PS_v1606)
, 0
, 0
, 0
, 0
, 900009
, useLabel(ST_v1605)
,	/* CT_v1609: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip[] = {
  CAPTAG(useLabel(FN_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip),2)
, useLabel(PS_v1604)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Data_46Fixed_46fixedResolution))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46_42))
, VAPTAG(useLabel(FN_Prelude_46Integral_46Prelude_46Integer_46div))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1615)
,};
Node FN_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,2)
, bytes2word(HEAP_OFF_N1,13,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,12)
, bytes2word(HEAP_ARG,3,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1614)
, 0
, 0
, 0
, 0
, useLabel(PS_v1613)
, 0
, 0
, 0
, 0
, useLabel(PS_v1612)
, 0
, 0
, 0
, 0
, 890009
, useLabel(ST_v1611)
,	/* CT_v1615: (byte 0) */
  HW(3,3)
, 0
,};
Node F0_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47[] = {
  CAPTAG(useLabel(FN_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47),3)
, useLabel(PS_v1610)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Data_46Fixed_46fixedResolution))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46_42))
, VAPTAG(useLabel(FN_Prelude_46Integral_46Prelude_46Integer_46div))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1621)
,};
Node FN_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,2,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG,1,2)
, bytes2word(HEAP_CVAL_P1,7,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(12,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,17,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,10,HEAP_OFF_N1)
, bytes2word(25,HEAP_OFF_N1,13,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1620)
, 0
, 0
, 0
, 0
, useLabel(PS_v1619)
, 0
, 0
, 0
, 0
, useLabel(PS_v1618)
, 0
, 0
, 0
, 0
, 860009
, useLabel(ST_v1617)
,	/* CT_v1621: (byte 0) */
  HW(4,2)
, 0
,};
Node F0_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational[] = {
  CAPTAG(useLabel(FN_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational),2)
, useLabel(PS_v1616)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Real_46Prelude_46Integer_46toRational))
, VAPTAG(useLabel(FN_Data_46Fixed_46fixedResolution))
, VAPTAG(useLabel(FN_Prelude_46Fractional_46Ratio_46Ratio_46_47))
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1626)
,};
Node FN_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,2,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,12,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v1625)
, 0
, 0
, 0
, 0
, useLabel(PS_v1624)
, 0
, 0
, 0
, 0
, 830009
, useLabel(ST_v1623)
,	/* CT_v1626: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger[] = {
  CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger),2)
, useLabel(PS_v1622)
, 0
, 0
, 0
, CAPTAG(useLabel(FN_LAMBDA1375),1)
, VAPTAG(useLabel(FN_Data_46Fixed_46withResolution))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1630)
,	/* FN_LAMBDA1375: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG_RET_EVAL,1,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1629)
, 0
, 0
, 0
, 0
, 830041
, useLabel(ST_v1628)
,	/* CT_v1630: (byte 0) */
  HW(1,2)
, 0
,	/* F0_LAMBDA1375: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA1375),2)
, useLabel(PS_v1627)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46_42))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1635)
,};
Node FN_Prelude_46Num_46Data_46Fixed_46Fixed_46signum[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,2,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,12,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v1634)
, 0
, 0
, 0
, 0
, useLabel(PS_v1633)
, 0
, 0
, 0
, 0
, 820009
, useLabel(ST_v1632)
,	/* CT_v1635: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Num_46Data_46Fixed_46Fixed_46signum[] = {
  CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46signum),2)
, useLabel(PS_v1631)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46signum))
, VAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1639)
,};
Node FN_Prelude_46Num_46Data_46Fixed_46Fixed_46abs[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1638)
, 0
, 0
, 0
, 0
, 810009
, useLabel(ST_v1637)
,	/* CT_v1639: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Num_46Data_46Fixed_46Fixed_46abs[] = {
  CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46abs),2)
, useLabel(PS_v1636)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46abs))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1643)
,};
Node FN_Prelude_46Num_46Data_46Fixed_46Fixed_46negate[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1642)
, 0
, 0
, 0
, 0
, 800009
, useLabel(ST_v1641)
,	/* CT_v1643: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Num_46Data_46Fixed_46Fixed_46negate[] = {
  CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46negate),2)
, useLabel(PS_v1640)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46negate))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1649)
,};
Node FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_42[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,2,3,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG_ARG,1)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,17,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,19,HEAP_OFF_N1)
, bytes2word(13,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1648)
, 0
, 0
, 0
, 0
, useLabel(PS_v1647)
, 0
, 0
, 0
, 0
, useLabel(PS_v1646)
, 0
, 0
, 0
, 0
, 790009
, useLabel(ST_v1645)
,	/* CT_v1649: (byte 0) */
  HW(3,3)
, 0
,};
Node F0_Prelude_46Num_46Data_46Fixed_46Fixed_46_42[] = {
  CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_42),3)
, useLabel(PS_v1644)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46_42))
, VAPTAG(useLabel(FN_Data_46Fixed_46fixedResolution))
, VAPTAG(useLabel(FN_Prelude_46Integral_46Prelude_46Integer_46div))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1653)
,};
Node FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_45[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG_ARG_RET_EVAL,2)
, bytes2word(3,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1652)
, 0
, 0
, 0
, 0
, 780009
, useLabel(ST_v1651)
,	/* CT_v1653: (byte 0) */
  HW(1,3)
, 0
,};
Node F0_Prelude_46Num_46Data_46Fixed_46Fixed_46_45[] = {
  CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_45),3)
, useLabel(PS_v1650)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46_45))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1657)
,};
Node FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_43[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG_ARG_RET_EVAL,2)
, bytes2word(3,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1656)
, 0
, 0
, 0
, 0
, 770009
, useLabel(ST_v1655)
,	/* CT_v1657: (byte 0) */
  HW(1,3)
, 0
,};
Node F0_Prelude_46Num_46Data_46Fixed_46Fixed_46_43[] = {
  CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_43),3)
, useLabel(PS_v1654)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Integer_46_43))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1662)
,};
Node FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,9,HEAP_OFF_N1)
, bytes2word(14,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1661)
, 0
, 0
, 0
, 0
, useLabel(PS_v1660)
, 0
, 0
, 0
, 0
, 740009
, useLabel(ST_v1659)
,	/* CT_v1662: (byte 0) */
  HW(3,3)
, 0
,};
Node F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo[] = {
  CAPTAG(useLabel(FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo),3)
, useLabel(PS_v1658)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Enum_46Prelude_46Integer_46enumFromThenTo))
, VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46_91_93_46fmap))
, useLabel(F0_NHC_46Internal_46_95id)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1667)
,};
Node FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1)
, bytes2word(9,HEAP_OFF_N1,13,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1666)
, 0
, 0
, 0
, 0
, useLabel(PS_v1665)
, 0
, 0
, 0
, 0
, 730009
, useLabel(ST_v1664)
,	/* CT_v1667: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo[] = {
  CAPTAG(useLabel(FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo),2)
, useLabel(PS_v1663)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Enum_46Prelude_46Integer_46enumFromTo))
, VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46_91_93_46fmap))
, useLabel(F0_NHC_46Internal_46_95id)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1672)
,};
Node FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG_ARG,1,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1)
, bytes2word(9,HEAP_OFF_N1,13,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1671)
, 0
, 0
, 0
, 0
, useLabel(PS_v1670)
, 0
, 0
, 0
, 0
, 720009
, useLabel(ST_v1669)
,	/* CT_v1672: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen[] = {
  CAPTAG(useLabel(FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen),2)
, useLabel(PS_v1668)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Enum_46Prelude_46Integer_46enumFromThen))
, VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46_91_93_46fmap))
, useLabel(F0_NHC_46Internal_46_95id)
, bytes2word(1,0,0,1)
, useLabel(CT_v1677)
,};
Node FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1,9)
, bytes2word(HEAP_OFF_N1,12,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v1676)
, 0
, 0
, 0
, 0
, useLabel(PS_v1675)
, 0
, 0
, 0
, 0
, 710009
, useLabel(ST_v1674)
,	/* CT_v1677: (byte 0) */
  HW(3,1)
, 0
,};
Node F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom[] = {
  CAPTAG(useLabel(FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom),1)
, useLabel(PS_v1673)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Enum_46Prelude_46Integer_46enumFrom))
, VAPTAG(useLabel(FN_Prelude_46Functor_46Prelude_46_91_93_46fmap))
, useLabel(F0_NHC_46Internal_46_95id)
, bytes2word(1,0,0,1)
, useLabel(CT_v1681)
,};
Node FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46fromEnum[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1680)
, 0
, 0
, 0
, 0
, 700009
, useLabel(ST_v1679)
,	/* CT_v1681: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46fromEnum[] = {
  CAPTAG(useLabel(FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46fromEnum),1)
, useLabel(PS_v1678)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Enum_46Prelude_46Integer_46fromEnum))
, bytes2word(1,0,0,1)
, useLabel(CT_v1685)
,};
Node FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46toEnum[] = {
  bytes2word(NEEDHEAP_I32,PUSH_ARG_I1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_P1,9,ZAP_ARG_I1,EVAL)
, bytes2word(NEEDHEAP_I32,APPLY,1,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1684)
, 0
, 0
, 0
, 0
, 690009
, useLabel(ST_v1683)
,	/* CT_v1685: (byte 0) */
  HW(3,1)
, 0
,};
Node F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46toEnum[] = {
  CAPTAG(useLabel(FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46toEnum),1)
, useLabel(PS_v1682)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_46))
, useLabel(F0_NHC_46Internal_46_95id)
, useLabel(F0_Prelude_46Enum_46Prelude_46Integer_46toEnum)
, bytes2word(1,0,0,1)
, useLabel(CT_v1689)
,};
Node FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46pred[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1688)
, 0
, 0
, 0
, 0
, 680009
, useLabel(ST_v1687)
,	/* CT_v1689: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46pred[] = {
  CAPTAG(useLabel(FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46pred),1)
, useLabel(PS_v1686)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Enum_46Prelude_46Integer_46pred))
, bytes2word(1,0,0,1)
, useLabel(CT_v1693)
,};
Node FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46succ[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1692)
, 0
, 0
, 0
, 0
, 670009
, useLabel(ST_v1691)
,	/* CT_v1693: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46succ[] = {
  CAPTAG(useLabel(FN_Prelude_46Enum_46Data_46Fixed_46Fixed_46succ),1)
, useLabel(PS_v1690)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Enum_46Prelude_46Integer_46succ))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1698)
,};
Node FN_Data_46Fixed_46_95_46resolution[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,PUSH_ARG_I2,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,10)
, bytes2word(ZAP_ARG_I2,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1697)
, 0
, 0
, 0
, 0
, useLabel(PS_v1696)
, 0
, 0
, 0
, 0
, 0
, useLabel(ST_v1695)
,	/* CT_v1698: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Fixed_46_95_46resolution[] = {
  CAPTAG(useLabel(FN_Data_46Fixed_46_95_46resolution),2)
, useLabel(PS_v1694)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_LAMBDA1376))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95noMethodError))
, bytes2word(0,0,0,0)
, useLabel(CT_v1702)
,	/* FN_LAMBDA1376: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,8,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, 0
, 0
, 0
, 0
, useLabel(ST_v1701)
, 0
, useLabel(ST_v1700)
,	/* CT_v1702: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA1376: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA1376))
, useLabel(PS_v1699)
, 0
, 0
, 0
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v1709)
,};
Node FN_Data_46Fixed_46div_39[] = {
  bytes2word(NEEDHEAP_P1,43,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,11)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_N1,12,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,11)
, bytes2word(HEAP_ARG,4,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,17,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,10,HEAP_OFF_N1)
, bytes2word(26,HEAP_OFF_N1,14,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,11,HEAP_CVAL_N1,22)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1)
, bytes2word(10,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(15,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1708)
, 0
, 0
, 0
, 0
, useLabel(PS_v1707)
, 0
, 0
, 0
, 0
, useLabel(PS_v1706)
, 0
, 0
, 0
, 0
, useLabel(PS_v1705)
, 0
, 0
, 0
, 0
, 380001
, useLabel(ST_v1704)
,	/* CT_v1709: (byte 0) */
  HW(5,4)
, 0
,};
Node F0_Data_46Fixed_46div_39[] = {
  CAPTAG(useLabel(FN_Data_46Fixed_46div_39),4)
, useLabel(PS_v1703)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46toRational))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Fractional_46Ratio_46Ratio_46_47))
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, VAPTAG(useLabel(FN_Prelude_46RealFrac_46Ratio_46Ratio_46floor))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v1719)
,};
Node FN_Data_46Fixed_46mod_39[] = {
  bytes2word(NEEDHEAP_P1,72,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_P1,7,HEAP_CVAL_N1)
, bytes2word(7,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,11,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_P1,9,HEAP_CVAL_N1,17)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(11,HEAP_CVAL_P1,10,HEAP_CVAL_N1)
, bytes2word(22,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_P1,0,HEAP_ARG_ARG,2)
, bytes2word(3,HEAP_CVAL_P1,11,HEAP_CVAL_N1)
, bytes2word(27,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_OFF_N1,13,HEAP_CVAL_P1,12)
, bytes2word(HEAP_CVAL_P1,11,HEAP_CVAL_N1,27)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(26,HEAP_OFF_N1,13,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,13,HEAP_CVAL_N1,32)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(45,HEAP_OFF_N1,13,HEAP_ARG)
, bytes2word(3,PUSH_P1,0,PUSH_ARG_I2)
, bytes2word(HEAP_CVAL_P1,7,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,14)
, bytes2word(HEAP_CVAL_N1,37,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,11,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,ZAP_STACK_P1,4)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1718)
, 0
, 0
, 0
, 0
, useLabel(PS_v1717)
, 0
, 0
, 0
, 0
, useLabel(PS_v1716)
, 0
, 0
, 0
, 0
, useLabel(PS_v1715)
, 0
, 0
, 0
, 0
, useLabel(PS_v1714)
, 0
, 0
, 0
, 0
, useLabel(PS_v1713)
, 0
, 0
, 0
, 0
, useLabel(PS_v1712)
, 0
, 0
, 0
, 0
, 470001
, useLabel(ST_v1711)
,	/* CT_v1719: (byte 0) */
  HW(8,3)
, 0
,};
Node F0_Data_46Fixed_46mod_39[] = {
  CAPTAG(useLabel(FN_Data_46Fixed_46mod_39),3)
, useLabel(PS_v1710)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Real_46Prelude_46Num))
, VAPTAG(useLabel(FN_Prelude_46_42))
, VAPTAG(useLabel(FN_Prelude_46fromInteger))
, CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46185_46f),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Prelude_46_45))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v1723)
,	/* FN_Data_46Fixed_46Prelude_46185_46f: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG,1,4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1722)
, 0
, 0
, 0
, 0
, 480009
, useLabel(ST_v1721)
,	/* CT_v1723: (byte 0) */
  HW(1,4)
, 0
,	/* F0_Data_46Fixed_46Prelude_46185_46f: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46185_46f),4)
, useLabel(PS_v1720)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Data_46Fixed_46div_39))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v1734)
,};
Node FN_Data_46Fixed_46divMod_39[] = {
  bytes2word(NEEDHEAP_P1,102,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_P1)
, bytes2word(0,HEAP_ARG_ARG,3,4)
, bytes2word(HEAP_CVAL_P1,9,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(13,HEAP_ARG,2,HEAP_CVAL_P1)
, bytes2word(10,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_P1,11,HEAP_CVAL_N1,22)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(11,HEAP_CVAL_P1,10,HEAP_CVAL_N1)
, bytes2word(17,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,12)
, bytes2word(HEAP_CVAL_N1,27,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,11,HEAP_CVAL_P1)
, bytes2word(10,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_P1,13,HEAP_CVAL_N1,32)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_I1)
, bytes2word(HEAP_OFF_N1,12,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_P1,0,HEAP_ARG_ARG)
, bytes2word(3,4,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,13,HEAP_I1)
, bytes2word(HEAP_CVAL_P1,9,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(27,HEAP_OFF_N1,13,HEAP_CVAL_P1)
, bytes2word(14,HEAP_CVAL_N1,37,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1,46)
, bytes2word(HEAP_OFF_N1,13,HEAP_ARG,4)
, bytes2word(HEAP_CVAL_P1,14,HEAP_CVAL_N1,37)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_OFF_N1)
, bytes2word(66,HEAP_ARG,3,HEAP_OFF_N1)
, bytes2word(15,PUSH_HEAP,HEAP_CVAL_N1,42)
, bytes2word(HEAP_CVAL_N1,47,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_OFF_N1,87,HEAP_OFF_N1)
, bytes2word(14,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1733)
, 0
, 0
, 0
, 0
, CONSTR(0,2,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1732)
, 0
, 0
, 0
, 0
, useLabel(PS_v1731)
, 0
, 0
, 0
, 0
, useLabel(PS_v1730)
, 0
, 0
, 0
, 0
, useLabel(PS_v1729)
, 0
, 0
, 0
, 0
, useLabel(PS_v1728)
, 0
, 0
, 0
, 0
, useLabel(PS_v1727)
, 0
, 0
, 0
, 0
, useLabel(PS_v1726)
, 0
, 0
, 0
, 0
, 420001
, useLabel(ST_v1725)
,	/* CT_v1734: (byte 0) */
  HW(8,4)
, 0
,};
Node F0_Data_46Fixed_46divMod_39[] = {
  CAPTAG(useLabel(FN_Data_46Fixed_46divMod_39),4)
, useLabel(PS_v1724)
, 0
, 0
, 0
, useLabel(CF_Prelude_46Integral_46Prelude_46Integer)
, CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46182_46f),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Real_46Prelude_46Num))
, VAPTAG(useLabel(FN_Prelude_46_45))
, VAPTAG(useLabel(FN_Prelude_46_42))
, VAPTAG(useLabel(FN_Prelude_46fromIntegral))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v1738)
,	/* FN_Data_46Fixed_46Prelude_46182_46f: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG,1,4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1737)
, 0
, 0
, 0
, 0
, 430009
, useLabel(ST_v1736)
,	/* CT_v1738: (byte 0) */
  HW(1,4)
, 0
,	/* F0_Data_46Fixed_46Prelude_46182_46f: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Fixed_46Prelude_46182_46f),4)
, useLabel(PS_v1735)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Data_46Fixed_46div_39))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1742)
,};
Node FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46compare[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG_RET_EVAL,1,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1741)
, 0
, 0
, 0
, 0
, 500048
, useLabel(ST_v1740)
,	/* CT_v1742: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46compare[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46compare),2)
, useLabel(PS_v1739)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Integer_46compare))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1746)
,};
Node FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60_61[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG_RET_EVAL,1,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1745)
, 0
, 0
, 0
, 0
, 500048
, useLabel(ST_v1744)
,	/* CT_v1746: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60_61),2)
, useLabel(PS_v1743)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Integer_46_60_61))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1750)
,};
Node FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46min[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,8,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1749)
, 0
, 0
, 0
, 0
, 500048
, useLabel(ST_v1748)
,	/* CT_v1750: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46min[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46min),2)
, useLabel(PS_v1747)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_95_46min))
, useLabel(CF_Prelude_46Ord_46Data_46Fixed_46Fixed)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1754)
,};
Node FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46max[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,8,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1753)
, 0
, 0
, 0
, 0
, 500048
, useLabel(ST_v1752)
,	/* CT_v1754: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46max[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46max),2)
, useLabel(PS_v1751)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_95_46max))
, useLabel(CF_Prelude_46Ord_46Data_46Fixed_46Fixed)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1758)
,};
Node FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,8,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1757)
, 0
, 0
, 0
, 0
, 500048
, useLabel(ST_v1756)
,	/* CT_v1758: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62),2)
, useLabel(PS_v1755)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_95_46_62))
, useLabel(CF_Prelude_46Ord_46Data_46Fixed_46Fixed)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1762)
,};
Node FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62_61[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,8,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1761)
, 0
, 0
, 0
, 0
, 500048
, useLabel(ST_v1760)
,	/* CT_v1762: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62_61),2)
, useLabel(PS_v1759)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_95_46_62_61))
, useLabel(CF_Prelude_46Ord_46Data_46Fixed_46Fixed)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1766)
,};
Node FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,8,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1765)
, 0
, 0
, 0
, 0
, 500048
, useLabel(ST_v1764)
,	/* CT_v1766: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60),2)
, useLabel(PS_v1763)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_95_46_60))
, useLabel(CF_Prelude_46Ord_46Data_46Fixed_46Fixed)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1770)
,};
Node FN_Prelude_46Eq_46Data_46Fixed_46Fixed_46_61_61[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG_ARG_RET_EVAL,1,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1769)
, 0
, 0
, 0
, 0
, 500045
, useLabel(ST_v1768)
,	/* CT_v1770: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Fixed_46Fixed_46_61_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Fixed_46Fixed_46_61_61),2)
, useLabel(PS_v1767)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Eq_46Prelude_46Integer_46_61_61))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v1774)
,};
Node FN_Prelude_46Eq_46Data_46Fixed_46Fixed_46_47_61[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,8,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1773)
, 0
, 0
, 0
, 0
, 500045
, useLabel(ST_v1772)
,	/* CT_v1774: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Fixed_46Fixed_46_47_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Fixed_46Fixed_46_47_61),2)
, useLabel(PS_v1771)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46_95_46_47_61))
, useLabel(CF_Prelude_46Eq_46Data_46Fixed_46Fixed)
, bytes2word(0,0,0,0)
, useLabel(CT_v1778)
,};
Node FN_Prelude_46Eq_46Data_46Fixed_46Fixed[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1777)
, 0
, 0
, 0
, 0
, CONSTR(0,2,0)
, 0
, 0
, 0
, 0
, 500045
, useLabel(ST_v1776)
,	/* CT_v1778: (byte 0) */
  HW(2,0)
, 0
,};
Node CF_Prelude_46Eq_46Data_46Fixed_46Fixed[] = {
  VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Fixed_46Fixed))
, useLabel(PS_v1775)
, 0
, 0
, 0
, useLabel(F0_Prelude_46Eq_46Data_46Fixed_46Fixed_46_47_61)
, useLabel(F0_Prelude_46Eq_46Data_46Fixed_46Fixed_46_61_61)
, bytes2word(0,0,0,0)
, useLabel(CT_v1782)
,};
Node FN_Prelude_46Ord_46Data_46Fixed_46Fixed[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_P1,9,HEAP_CVAL_P1)
, bytes2word(10,HEAP_CVAL_P1,11,HEAP_CVAL_P1)
, bytes2word(12,HEAP_CVAL_P1,13,HEAP_CVAL_P1)
, bytes2word(14,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1781)
, 0
, 0
, 0
, 0
, CONSTR(0,8,0)
, 0
, 0
, 0
, 0
, 500048
, useLabel(ST_v1780)
,	/* CT_v1782: (byte 0) */
  HW(8,0)
, 0
,};
Node CF_Prelude_46Ord_46Data_46Fixed_46Fixed[] = {
  VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Fixed_46Fixed))
, useLabel(PS_v1779)
, 0
, 0
, 0
, useLabel(CF_Prelude_46Eq_46Data_46Fixed_46Fixed)
, useLabel(F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60)
, useLabel(F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60_61)
, useLabel(F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62_61)
, useLabel(F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62)
, useLabel(F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46compare)
, useLabel(F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46min)
, useLabel(F0_Prelude_46Ord_46Data_46Fixed_46Fixed_46max)
, bytes2word(1,0,0,1)
, useLabel(CT_v1785)
,};
Node FN_Data_46Fixed_46resolution[] = {
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,1)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 520007
, useLabel(ST_v1784)
,	/* CT_v1785: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_Data_46Fixed_46resolution[] = {
  CAPTAG(useLabel(FN_Data_46Fixed_46resolution),1)
, useLabel(PS_v1783)
, 0
, 0
, 0
, bytes2word(0,0,0,0)
, useLabel(CT_v1789)
,};
Node FN_Prelude_46Enum_46Data_46Fixed_46Fixed[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,HEAP_CVAL_P1,9,HEAP_CVAL_P1)
, bytes2word(10,HEAP_CVAL_P1,11,HEAP_CVAL_P1)
, bytes2word(12,HEAP_CVAL_P1,13,HEAP_CVAL_P1)
, bytes2word(14,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1788)
, 0
, 0
, 0
, 0
, CONSTR(0,8,0)
, 0
, 0
, 0
, 0
, 660010
, useLabel(ST_v1787)
,	/* CT_v1789: (byte 0) */
  HW(8,0)
, 0
,};
Node CF_Prelude_46Enum_46Data_46Fixed_46Fixed[] = {
  VAPTAG(useLabel(FN_Prelude_46Enum_46Data_46Fixed_46Fixed))
, useLabel(PS_v1786)
, 0
, 0
, 0
, useLabel(F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46succ)
, useLabel(F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46pred)
, useLabel(F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom)
, useLabel(F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46fromEnum)
, useLabel(F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46toEnum)
, useLabel(F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen)
, useLabel(F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo)
, useLabel(F0_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo)
, bytes2word(1,0,0,1)
, useLabel(CT_v1801)
,};
Node FN_Prelude_46Num_46Data_46Fixed_46Fixed[] = {
  bytes2word(NEEDHEAP_P1,71,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_CVAL_N1)
, bytes2word(12,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_CVAL_N1)
, bytes2word(22,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(11,HEAP_CVAL_N1,27,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,12,HEAP_CVAL_N1)
, bytes2word(32,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(13,HEAP_CVAL_N1,37,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,14,HEAP_CVAL_N1)
, bytes2word(42,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(47,HEAP_CVAL_N1,52,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_CVAL_P1,15)
, bytes2word(HEAP_P1,8,HEAP_P1,7)
, bytes2word(HEAP_P1,6,HEAP_P1,5)
, bytes2word(HEAP_P1,4,HEAP_P1,3)
, bytes2word(HEAP_I2,HEAP_I1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, useLabel(PS_v1800)
, 0
, 0
, 0
, 0
, CONSTR(0,9,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1799)
, 0
, 0
, 0
, 0
, useLabel(PS_v1798)
, 0
, 0
, 0
, 0
, useLabel(PS_v1797)
, 0
, 0
, 0
, 0
, useLabel(PS_v1796)
, 0
, 0
, 0
, 0
, useLabel(PS_v1795)
, 0
, 0
, 0
, 0
, useLabel(PS_v1794)
, 0
, 0
, 0
, 0
, useLabel(PS_v1793)
, 0
, 0
, 0
, 0
, useLabel(PS_v1792)
, 0
, 0
, 0
, 0
, 760031
, useLabel(ST_v1791)
,	/* CT_v1801: (byte 0) */
  HW(9,1)
, 0
,};
Node F0_Prelude_46Num_46Data_46Fixed_46Fixed[] = {
  CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed),1)
, useLabel(PS_v1790)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed))
, CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_42),2)
, CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_43),2)
, CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46_45),2)
, CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46negate),1)
, CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46signum),1)
, CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger),1)
, CAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed_46abs),1)
, useLabel(CF_Prelude_46Eq_46Data_46Fixed_46Fixed)
, bytes2word(1,0,0,1)
, useLabel(CT_v1807)
,};
Node FN_Prelude_46Real_46Data_46Fixed_46Fixed[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_N1,7,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_ARG,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_N1,12)
, bytes2word(HEAP_CREATE,HEAP_SPACE,HEAP_SPACE,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,17)
, bytes2word(HEAP_CVAL_N1,22,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_I2,HEAP_CVAL_P1,9)
, bytes2word(HEAP_I1,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1806)
, 0
, 0
, 0
, 0
, CONSTR(0,3,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1805)
, 0
, 0
, 0
, 0
, useLabel(PS_v1804)
, 0
, 0
, 0
, 0
, 850031
, useLabel(ST_v1803)
,	/* CT_v1807: (byte 0) */
  HW(3,1)
, 0
,};
Node F0_Prelude_46Real_46Data_46Fixed_46Fixed[] = {
  CAPTAG(useLabel(FN_Prelude_46Real_46Data_46Fixed_46Fixed),1)
, useLabel(PS_v1802)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed))
, CAPTAG(useLabel(FN_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational),1)
, useLabel(CF_Prelude_46Ord_46Data_46Fixed_46Fixed)
, bytes2word(1,0,0,1)
, useLabel(CT_v1815)
,};
Node FN_Prelude_46Fractional_46Data_46Fixed_46Fixed[] = {
  bytes2word(NEEDHEAP_P1,38,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_CVAL_N1)
, bytes2word(12,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_CVAL_N1)
, bytes2word(22,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(27,HEAP_CVAL_N1,32,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_P1,4)
, bytes2word(HEAP_P1,3,HEAP_I2,HEAP_I1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1814)
, 0
, 0
, 0
, 0
, CONSTR(0,4,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1813)
, 0
, 0
, 0
, 0
, useLabel(PS_v1812)
, 0
, 0
, 0
, 0
, useLabel(PS_v1811)
, 0
, 0
, 0
, 0
, useLabel(PS_v1810)
, 0
, 0
, 0
, 0
, 880031
, useLabel(ST_v1809)
,	/* CT_v1815: (byte 0) */
  HW(4,1)
, 0
,};
Node F0_Prelude_46Fractional_46Data_46Fixed_46Fixed[] = {
  CAPTAG(useLabel(FN_Prelude_46Fractional_46Data_46Fixed_46Fixed),1)
, useLabel(PS_v1808)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Num_46Data_46Fixed_46Fixed))
, CAPTAG(useLabel(FN_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47),2)
, CAPTAG(useLabel(FN_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational),1)
, CAPTAG(useLabel(FN_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v1826)
,};
Node FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed[] = {
  bytes2word(NEEDHEAP_P1,62,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_CVAL_N1)
, bytes2word(12,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_CVAL_N1)
, bytes2word(22,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(11,HEAP_CVAL_N1,27,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,12,HEAP_CVAL_N1)
, bytes2word(32,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(13,HEAP_CVAL_N1,37,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,42,HEAP_CVAL_N1)
, bytes2word(47,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_P1,7,HEAP_P1,6)
, bytes2word(HEAP_P1,5,HEAP_P1,4)
, bytes2word(HEAP_P1,3,HEAP_I2,HEAP_I1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, useLabel(PS_v1825)
, 0
, 0
, 0
, 0
, CONSTR(0,7,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1824)
, 0
, 0
, 0
, 0
, useLabel(PS_v1823)
, 0
, 0
, 0
, 0
, useLabel(PS_v1822)
, 0
, 0
, 0
, 0
, useLabel(PS_v1821)
, 0
, 0
, 0
, 0
, useLabel(PS_v1820)
, 0
, 0
, 0
, 0
, useLabel(PS_v1819)
, 0
, 0
, 0
, 0
, useLabel(PS_v1818)
, 0
, 0
, 0
, 0
, 940031
, useLabel(ST_v1817)
,	/* CT_v1826: (byte 0) */
  HW(7,1)
, 0
,};
Node F0_Prelude_46RealFrac_46Data_46Fixed_46Fixed[] = {
  CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed),1)
, useLabel(PS_v1816)
, 0
, 0
, 0
, VAPTAG(useLabel(FN_Prelude_46Real_46Data_46Fixed_46Fixed))
, VAPTAG(useLabel(FN_Prelude_46Fractional_46Data_46Fixed_46Fixed))
, CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round),2)
, CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate),2)
, CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling),2)
, CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction),2)
, CAPTAG(useLabel(FN_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v1834)
,};
Node FN_Prelude_46Show_46Data_46Fixed_46Fixed[] = {
  bytes2word(NEEDHEAP_P1,38,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_N1,7,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_CVAL_N1)
, bytes2word(12,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_CVAL_N1,17,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_CVAL_N1)
, bytes2word(22,HEAP_CREATE,HEAP_SPACE,HEAP_SPACE)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(27,HEAP_CVAL_N1,32,HEAP_CREATE)
, bytes2word(HEAP_SPACE,HEAP_SPACE,HEAP_P1,4)
, bytes2word(HEAP_P1,3,HEAP_I2,HEAP_I1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1833)
, 0
, 0
, 0
, 0
, CONSTR(0,4,0)
, 0
, 0
, 0
, 0
, useLabel(PS_v1832)
, 0
, 0
, 0
, 0
, useLabel(PS_v1831)
, 0
, 0
, 0
, 0
, useLabel(PS_v1830)
, 0
, 0
, 0
, 0
, useLabel(PS_v1829)
, 0
, 0
, 0
, 0
, 1290031
, useLabel(ST_v1828)
,	/* CT_v1834: (byte 0) */
  HW(4,1)
, 0
,};
Node F0_Prelude_46Show_46Data_46Fixed_46Fixed[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed),1)
, useLabel(PS_v1827)
, 0
, 0
, 0
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec),2)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed_46showList),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Fixed_46Fixed_46show),1)
, bytes2word(0,0,0,0)
, useLabel(CT_v1838)
,};
Node FN_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,7,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1837)
, 0
, 0
, 0
, 0
, CONSTR(0,1,0)
, 0
, 0
, 0
, 0
, 1360010
, useLabel(ST_v1836)
,	/* CT_v1838: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6[] = {
  VAPTAG(useLabel(FN_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6))
, useLabel(PS_v1835)
, 0
, 0
, 0
, useLabel(F0_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6_46resolution)
, bytes2word(0,0,0,0)
, useLabel(CT_v1842)
,};
Node FN_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,7)
, bytes2word(HEAP_CVAL_N1,12,HEAP_CREATE,HEAP_SPACE)
, bytes2word(HEAP_SPACE,HEAP_CVAL_P1,7,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, useLabel(PS_v1841)
, 0
, 0
, 0
, 0
, CONSTR(0,1,0)
, 0
, 0
, 0
, 0
, 1440010
, useLabel(ST_v1840)
,	/* CT_v1842: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12[] = {
  VAPTAG(useLabel(FN_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12))
, useLabel(PS_v1839)
, 0
, 0
, 0
, useLabel(F0_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12_46resolution)
,	/* ST_v1432: (byte 0) */
 	/* ST_v1529: (byte 1) */
  bytes2word(0,45,0,0)
,};
Node PM_Data_46Fixed[] = {
 	/* ST_v1404: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,0,0)
,};
Node PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12[] = {
 };
Node PC_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12[] = {
 	/* ST_v1840: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,72)
, bytes2word(97,115,82,101)
, bytes2word(115,111,108,117)
, bytes2word(116,105,111,110)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(69,49,50,0)
,};
Node PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12_46resolution[] = {
 };
Node PC_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12_46resolution[] = {
 	/* ST_v1406: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,72)
, bytes2word(97,115,82,101)
, bytes2word(115,111,108,117)
, bytes2word(116,105,111,110)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(69,49,50,46)
, bytes2word(114,101,115,111)
, bytes2word(108,117,116,105)
, bytes2word(111,110,0,0)
,};
Node PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6[] = {
 };
Node PC_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6[] = {
 	/* ST_v1836: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,72)
, bytes2word(97,115,82,101)
, bytes2word(115,111,108,117)
, bytes2word(116,105,111,110)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(69,54,0,0)
,};
Node PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6_46resolution[] = {
 };
Node PC_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6_46resolution[] = {
 	/* ST_v1409: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,72)
, bytes2word(97,115,82,101)
, bytes2word(115,111,108,117)
, bytes2word(116,105,111,110)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(69,54,46,114)
, bytes2word(101,115,111,108)
, bytes2word(117,116,105,111)
, bytes2word(110,0,0,0)
,};
Node PP_Data_46Fixed_46_95_46resolution[] = {
 };
Node PC_Data_46Fixed_46_95_46resolution[] = {
 	/* ST_v1695: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,95)
, bytes2word(46,114,101,115)
, bytes2word(111,108,117,116)
,	/* PP_LAMBDA1376: (byte 4) */
 	/* PC_LAMBDA1376: (byte 4) */
 	/* ST_v1700: (byte 4) */
  bytes2word(105,111,110,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,95)
, bytes2word(46,114,101,115)
, bytes2word(111,108,117,116)
, bytes2word(105,111,110,58)
, bytes2word(110,111,112,111)
,	/* PP_Data_46Fixed_46chopZeros: (byte 2) */
 	/* PC_Data_46Fixed_46chopZeros: (byte 2) */
 	/* ST_v1443: (byte 2) */
  bytes2word(115,0,68,97)
, bytes2word(116,97,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,99,104,111)
, bytes2word(112,90,101,114)
,	/* PP_LAMBDA1368: (byte 3) */
 	/* PC_LAMBDA1368: (byte 3) */
 	/* ST_v1452: (byte 3) */
  bytes2word(111,115,0,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,99,104)
, bytes2word(111,112,90,101)
, bytes2word(114,111,115,58)
, bytes2word(49,48,51,58)
, bytes2word(49,53,45,49)
, bytes2word(48,51,58,49)
, bytes2word(54,0,0,0)
,};
Node PP_Data_46Fixed_46div_39[] = {
 };
Node PC_Data_46Fixed_46div_39[] = {
 	/* ST_v1704: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,100)
, bytes2word(105,118,39,0)
,};
Node PP_Data_46Fixed_46divMod_39[] = {
 };
Node PC_Data_46Fixed_46divMod_39[] = {
 	/* ST_v1725: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,100)
, bytes2word(105,118,77,111)
,	/* PP_Data_46Fixed_46Prelude_46182_46f: (byte 3) */
 	/* PC_Data_46Fixed_46Prelude_46182_46f: (byte 3) */
 	/* ST_v1736: (byte 3) */
  bytes2word(100,39,0,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,100,105)
, bytes2word(118,77,111,100)
, bytes2word(39,58,52,51)
, bytes2word(58,57,45,52)
, bytes2word(51,58,50,48)
,	/* PP_Data_46Fixed_46fixedResolution: (byte 1) */
 	/* PC_Data_46Fixed_46fixedResolution: (byte 1) */
 	/* ST_v1412: (byte 1) */
  bytes2word(0,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(102,105,120,101)
, bytes2word(100,82,101,115)
, bytes2word(111,108,117,116)
,	/* PP_Data_46Fixed_46Prelude_46188_46uf: (byte 4) */
 	/* PC_Data_46Fixed_46Prelude_46188_46uf: (byte 4) */
 	/* ST_v1418: (byte 4) */
  bytes2word(105,111,110,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,102)
, bytes2word(105,120,101,100)
, bytes2word(82,101,115,111)
, bytes2word(108,117,116,105)
, bytes2word(111,110,58,53)
, bytes2word(56,58,57,45)
, bytes2word(53,56,58,50)
, bytes2word(52,0,0,0)
,};
Node PP_Data_46Fixed_46mod_39[] = {
 };
Node PC_Data_46Fixed_46mod_39[] = {
 	/* ST_v1711: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,109)
,	/* PP_Data_46Fixed_46Prelude_46185_46f: (byte 4) */
 	/* PC_Data_46Fixed_46Prelude_46185_46f: (byte 4) */
 	/* ST_v1721: (byte 4) */
  bytes2word(111,100,39,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,109)
, bytes2word(111,100,39,58)
, bytes2word(52,56,58,57)
, bytes2word(45,52,56,58)
, bytes2word(50,48,0,0)
,};
Node PP_Data_46Fixed_46resolution[] = {
 };
Node PC_Data_46Fixed_46resolution[] = {
 	/* ST_v1784: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,114)
, bytes2word(101,115,111,108)
, bytes2word(117,116,105,111)
, bytes2word(110,0,0,0)
,};
Node PP_Data_46Fixed_46showFixed[] = {
 };
Node PC_Data_46Fixed_46showFixed[] = {
 	/* ST_v1488: (byte 0) */
  bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,115)
, bytes2word(104,111,119,70)
, bytes2word(105,120,101,100)
,	/* PP_LAMBDA1371: (byte 1) */
 	/* PC_LAMBDA1371: (byte 1) */
 	/* ST_v1528: (byte 1) */
  bytes2word(0,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(115,104,111,119)
, bytes2word(70,105,120,101)
, bytes2word(100,58,49,50)
, bytes2word(48,58,53,52)
, bytes2word(45,49,50,48)
,	/* PP_LAMBDA1372: (byte 4) */
 	/* PC_LAMBDA1372: (byte 4) */
 	/* ST_v1525: (byte 4) */
  bytes2word(58,53,54,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,115)
, bytes2word(104,111,119,70)
, bytes2word(105,120,101,100)
, bytes2word(58,49,50,51)
,	/* PP_LAMBDA1373: (byte 4) */
 	/* PC_LAMBDA1373: (byte 4) */
 	/* ST_v1522: (byte 4) */
  bytes2word(58,49,48,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,115)
, bytes2word(104,111,119,70)
, bytes2word(105,120,101,100)
, bytes2word(58,49,50,51)
,	/* PP_Data_46Fixed_46Prelude_46271_46digits: (byte 4) */
 	/* PC_Data_46Fixed_46Prelude_46271_46digits: (byte 4) */
 	/* ST_v1516: (byte 4) */
  bytes2word(58,49,50,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,115)
, bytes2word(104,111,119,70)
, bytes2word(105,120,101,100)
, bytes2word(58,49,50,53)
, bytes2word(58,57,45,49)
, bytes2word(50,53,58,54)
,	/* PP_Data_46Fixed_46Prelude_46272_46maxnum: (byte 2) */
 	/* PC_Data_46Fixed_46Prelude_46272_46maxnum: (byte 2) */
 	/* ST_v1509: (byte 2) */
  bytes2word(53,0,68,97)
, bytes2word(116,97,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,115,104,111)
, bytes2word(119,70,105,120)
, bytes2word(101,100,58,49)
, bytes2word(50,54,58,57)
, bytes2word(45,49,50,54)
,	/* PP_Data_46Fixed_46showIntegerZeros: (byte 4) */
 	/* PC_Data_46Fixed_46showIntegerZeros: (byte 4) */
 	/* ST_v1463: (byte 4) */
  bytes2word(58,50,56,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,115)
, bytes2word(104,111,119,73)
, bytes2word(110,116,101,103)
, bytes2word(101,114,90,101)
,	/* PP_LAMBDA1369: (byte 4) */
 	/* PC_LAMBDA1369: (byte 4) */
 	/* ST_v1481: (byte 4) */
  bytes2word(114,111,115,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,115)
, bytes2word(104,111,119,73)
, bytes2word(110,116,101,103)
, bytes2word(101,114,90,101)
, bytes2word(114,111,115,58)
, bytes2word(49,48,57,58)
, bytes2word(50,57,45,49)
, bytes2word(48,57,58,51)
,	/* PP_LAMBDA1370: (byte 2) */
 	/* PC_LAMBDA1370: (byte 2) */
 	/* ST_v1477: (byte 2) */
  bytes2word(48,0,68,97)
, bytes2word(116,97,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,115,104,111)
, bytes2word(119,73,110,116)
, bytes2word(101,103,101,114)
, bytes2word(90,101,114,111)
, bytes2word(115,58,49,49)
, bytes2word(50,58,49,52)
, bytes2word(45,49,49,50)
,	/* PP_Data_46Fixed_46withDot: (byte 4) */
 	/* PC_Data_46Fixed_46withDot: (byte 4) */
 	/* ST_v1425: (byte 4) */
  bytes2word(58,53,55,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,119)
, bytes2word(105,116,104,68)
,	/* PP_LAMBDA1367: (byte 3) */
 	/* PC_LAMBDA1367: (byte 3) */
 	/* ST_v1431: (byte 3) */
  bytes2word(111,116,0,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,119,105)
, bytes2word(116,104,68,111)
, bytes2word(116,58,49,49)
, bytes2word(53,58,49,52)
, bytes2word(45,49,49,53)
,	/* PP_Data_46Fixed_46withResolution: (byte 4) */
 	/* PC_Data_46Fixed_46withResolution: (byte 4) */
 	/* ST_v1588: (byte 4) */
  bytes2word(58,49,53,0)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,119)
, bytes2word(105,116,104,82)
, bytes2word(101,115,111,108)
, bytes2word(117,116,105,111)
,	/* PP_Data_46Fixed_46withType: (byte 2) */
 	/* PC_Data_46Fixed_46withType: (byte 2) */
 	/* ST_v1585: (byte 2) */
  bytes2word(110,0,68,97)
, bytes2word(116,97,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,119,105,116)
, bytes2word(104,84,121,112)
,	/* ST_v1701: (byte 2) */
  bytes2word(101,0,78,111)
, bytes2word(32,100,101,102)
, bytes2word(97,117,108,116)
, bytes2word(32,100,101,102)
, bytes2word(105,110,105,116)
, bytes2word(105,111,110,32)
, bytes2word(102,111,114,32)
, bytes2word(99,108,97,115)
, bytes2word(115,32,109,101)
, bytes2word(116,104,111,100)
, bytes2word(32,114,101,115)
, bytes2word(111,108,117,116)
, bytes2word(105,111,110,0)
,};
Node PP_Prelude_46Enum_46Data_46Fixed_46Fixed[] = {
 };
Node PC_Prelude_46Enum_46Data_46Fixed_46Fixed[] = {
 	/* ST_v1787: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,110,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,0,0,0)
,};
Node PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom[] = {
 };
Node PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom[] = {
 	/* ST_v1674: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,110,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,101,110)
, bytes2word(117,109,70,114)
, bytes2word(111,109,0,0)
,};
Node PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen[] = {
 };
Node PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen[] = {
 	/* ST_v1669: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,110,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,101,110)
, bytes2word(117,109,70,114)
, bytes2word(111,109,84,104)
, bytes2word(101,110,0,0)
,};
Node PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo[] = {
 };
Node PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo[] = {
 	/* ST_v1659: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,110,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,101,110)
, bytes2word(117,109,70,114)
, bytes2word(111,109,84,104)
, bytes2word(101,110,84,111)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo[] = {
 };
Node PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo[] = {
 	/* ST_v1664: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,110,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,101,110)
, bytes2word(117,109,70,114)
, bytes2word(111,109,84,111)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46fromEnum[] = {
 };
Node PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46fromEnum[] = {
 	/* ST_v1679: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,110,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,102,114)
, bytes2word(111,109,69,110)
, bytes2word(117,109,0,0)
,};
Node PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46pred[] = {
 };
Node PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46pred[] = {
 	/* ST_v1687: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,110,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,112,114)
, bytes2word(101,100,0,0)
,};
Node PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46succ[] = {
 };
Node PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46succ[] = {
 	/* ST_v1691: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,110,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,115,117)
, bytes2word(99,99,0,0)
,};
Node PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46toEnum[] = {
 };
Node PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46toEnum[] = {
 	/* ST_v1683: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,110,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,116,111)
, bytes2word(69,110,117,109)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Eq_46Data_46Fixed_46Fixed[] = {
 };
Node PC_Prelude_46Eq_46Data_46Fixed_46Fixed[] = {
 	/* ST_v1776: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,113,46,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,70,105)
, bytes2word(120,101,100,0)
,};
Node PP_Prelude_46Eq_46Data_46Fixed_46Fixed_46_47_61[] = {
 };
Node PC_Prelude_46Eq_46Data_46Fixed_46Fixed_46_47_61[] = {
 	/* ST_v1772: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,113,46,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(47,61,0,0)
,};
Node PP_Prelude_46Eq_46Data_46Fixed_46Fixed_46_61_61[] = {
 };
Node PC_Prelude_46Eq_46Data_46Fixed_46Fixed_46_61_61[] = {
 	/* ST_v1768: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(69,113,46,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(61,61,0,0)
,};
Node PP_Prelude_46Fractional_46Data_46Fixed_46Fixed[] = {
 };
Node PC_Prelude_46Fractional_46Data_46Fixed_46Fixed[] = {
 	/* ST_v1809: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,114,97,99)
, bytes2word(116,105,111,110)
, bytes2word(97,108,46,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,70,105)
, bytes2word(120,101,100,0)
,};
Node PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47[] = {
 };
Node PC_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47[] = {
 	/* ST_v1611: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,114,97,99)
, bytes2word(116,105,111,110)
, bytes2word(97,108,46,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(47,0,0,0)
,};
Node PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational[] = {
 };
Node PC_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational[] = {
 	/* ST_v1594: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,114,97,99)
, bytes2word(116,105,111,110)
, bytes2word(97,108,46,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(102,114,111,109)
, bytes2word(82,97,116,105)
, bytes2word(111,110,97,108)
,	/* PP_LAMBDA1374: (byte 1) */
 	/* PC_LAMBDA1374: (byte 1) */
 	/* ST_v1599: (byte 1) */
  bytes2word(0,80,114,101)
, bytes2word(108,117,100,101)
, bytes2word(46,70,114,97)
, bytes2word(99,116,105,111)
, bytes2word(110,97,108,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,102,114,111)
, bytes2word(109,82,97,116)
, bytes2word(105,111,110,97)
, bytes2word(108,58,57,50)
, bytes2word(58,52,50,45)
, bytes2word(57,50,58,56)
, bytes2word(55,0,0,0)
,};
Node PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip[] = {
 };
Node PC_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip[] = {
 	/* ST_v1605: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(70,114,97,99)
, bytes2word(116,105,111,110)
, bytes2word(97,108,46,68)
, bytes2word(97,116,97,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(114,101,99,105)
, bytes2word(112,0,0,0)
,};
Node PP_Prelude_46Num_46Data_46Fixed_46Fixed[] = {
 };
Node PC_Prelude_46Num_46Data_46Fixed_46Fixed[] = {
 	/* ST_v1791: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(78,117,109,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_42[] = {
 };
Node PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_42[] = {
 	/* ST_v1645: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(78,117,109,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,42,0,0)
,};
Node PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_43[] = {
 };
Node PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_43[] = {
 	/* ST_v1655: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(78,117,109,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,43,0,0)
,};
Node PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_45[] = {
 };
Node PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_45[] = {
 	/* ST_v1651: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(78,117,109,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,45,0,0)
,};
Node PP_Prelude_46Num_46Data_46Fixed_46Fixed_46abs[] = {
 };
Node PC_Prelude_46Num_46Data_46Fixed_46Fixed_46abs[] = {
 	/* ST_v1637: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(78,117,109,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,97,98,115)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger[] = {
 };
Node PC_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger[] = {
 	/* ST_v1623: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(78,117,109,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,102,114,111)
, bytes2word(109,73,110,116)
, bytes2word(101,103,101,114)
,	/* PP_LAMBDA1375: (byte 1) */
 	/* PC_LAMBDA1375: (byte 1) */
 	/* ST_v1628: (byte 1) */
  bytes2word(0,80,114,101)
, bytes2word(108,117,100,101)
, bytes2word(46,78,117,109)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,102,114)
, bytes2word(111,109,73,110)
, bytes2word(116,101,103,101)
, bytes2word(114,58,56,51)
, bytes2word(58,52,49,45)
, bytes2word(56,51,58,54)
, bytes2word(53,0,0,0)
,};
Node PP_Prelude_46Num_46Data_46Fixed_46Fixed_46negate[] = {
 };
Node PC_Prelude_46Num_46Data_46Fixed_46Fixed_46negate[] = {
 	/* ST_v1641: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(78,117,109,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,110,101,103)
, bytes2word(97,116,101,0)
,};
Node PP_Prelude_46Num_46Data_46Fixed_46Fixed_46signum[] = {
 };
Node PC_Prelude_46Num_46Data_46Fixed_46Fixed_46signum[] = {
 	/* ST_v1632: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(78,117,109,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,115,105,103)
, bytes2word(110,117,109,0)
,};
Node PP_Prelude_46Ord_46Data_46Fixed_46Fixed[] = {
 };
Node PC_Prelude_46Ord_46Data_46Fixed_46Fixed[] = {
 	/* ST_v1780: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(79,114,100,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60[] = {
 };
Node PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60[] = {
 	/* ST_v1764: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(79,114,100,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,60,0,0)
,};
Node PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60_61[] = {
 };
Node PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60_61[] = {
 	/* ST_v1744: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(79,114,100,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,60,61,0)
,};
Node PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62[] = {
 };
Node PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62[] = {
 	/* ST_v1756: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(79,114,100,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,62,0,0)
,};
Node PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62_61[] = {
 };
Node PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62_61[] = {
 	/* ST_v1760: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(79,114,100,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,62,61,0)
,};
Node PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46compare[] = {
 };
Node PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46compare[] = {
 	/* ST_v1740: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(79,114,100,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,99,111,109)
, bytes2word(112,97,114,101)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46max[] = {
 };
Node PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46max[] = {
 	/* ST_v1752: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(79,114,100,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,109,97,120)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46min[] = {
 };
Node PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46min[] = {
 	/* ST_v1748: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(79,114,100,46)
, bytes2word(68,97,116,97)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,109,105,110)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46Real_46Data_46Fixed_46Fixed[] = {
 };
Node PC_Prelude_46Real_46Data_46Fixed_46Fixed[] = {
 	/* ST_v1803: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(82,101,97,108)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,0,0,0)
,};
Node PP_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational[] = {
 };
Node PC_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational[] = {
 	/* ST_v1617: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(82,101,97,108)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,116,111)
, bytes2word(82,97,116,105)
, bytes2word(111,110,97,108)
, bytes2word(0,0,0,0)
,};
Node PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed[] = {
 };
Node PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed[] = {
 	/* ST_v1817: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(82,101,97,108)
, bytes2word(70,114,97,99)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,0,0,0)
,};
Node PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling[] = {
 };
Node PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling[] = {
 	/* ST_v1557: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(82,101,97,108)
, bytes2word(70,114,97,99)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,99,101)
, bytes2word(105,108,105,110)
, bytes2word(103,0,0,0)
,};
Node PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor[] = {
 };
Node PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor[] = {
 	/* ST_v1552: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(82,101,97,108)
, bytes2word(70,114,97,99)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,102,108)
, bytes2word(111,111,114,0)
,};
Node PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction[] = {
 };
Node PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction[] = {
 	/* ST_v1572: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(82,101,97,108)
, bytes2word(70,114,97,99)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,112,114)
, bytes2word(111,112,101,114)
, bytes2word(70,114,97,99)
, bytes2word(116,105,111,110)
,	/* PP_Data_46Fixed_46Prelude_46245_46i: (byte 1) */
 	/* PC_Data_46Fixed_46Prelude_46245_46i: (byte 1) */
 	/* ST_v1581: (byte 1) */
  bytes2word(0,80,114,101)
, bytes2word(108,117,100,101)
, bytes2word(46,82,101,97)
, bytes2word(108,70,114,97)
, bytes2word(99,46,68,97)
, bytes2word(116,97,46,70)
, bytes2word(105,120,101,100)
, bytes2word(46,70,105,120)
, bytes2word(101,100,46,112)
, bytes2word(114,111,112,101)
, bytes2word(114,70,114,97)
, bytes2word(99,116,105,111)
, bytes2word(110,58,57,54)
, bytes2word(58,49,55,45)
, bytes2word(57,54,58,51)
, bytes2word(48,0,0,0)
,};
Node PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round[] = {
 };
Node PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round[] = {
 	/* ST_v1562: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(82,101,97,108)
, bytes2word(70,114,97,99)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,114,111)
, bytes2word(117,110,100,0)
,};
Node PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate[] = {
 };
Node PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate[] = {
 	/* ST_v1567: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(82,101,97,108)
, bytes2word(70,114,97,99)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,116,114)
, bytes2word(117,110,99,97)
, bytes2word(116,101,0,0)
,};
Node PP_Prelude_46Show_46Data_46Fixed_46Fixed[] = {
 };
Node PC_Prelude_46Show_46Data_46Fixed_46Fixed[] = {
 	/* ST_v1828: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(83,104,111,119)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,0,0,0)
,};
Node PP_Prelude_46Show_46Data_46Fixed_46Fixed_46show[] = {
 };
Node PC_Prelude_46Show_46Data_46Fixed_46Fixed_46show[] = {
 	/* ST_v1532: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(83,104,111,119)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,115,104)
, bytes2word(111,119,0,0)
,};
Node PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showList[] = {
 };
Node PC_Prelude_46Show_46Data_46Fixed_46Fixed_46showList[] = {
 	/* ST_v1542: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(83,104,111,119)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,115,104)
, bytes2word(111,119,76,105)
, bytes2word(115,116,0,0)
,};
Node PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec[] = {
 };
Node PC_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec[] = {
 	/* ST_v1547: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(83,104,111,119)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,115,104)
, bytes2word(111,119,115,80)
, bytes2word(114,101,99,0)
,};
Node PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType[] = {
 };
Node PC_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType[] = {
 	/* ST_v1537: (byte 0) */
  bytes2word(80,114,101,108)
, bytes2word(117,100,101,46)
, bytes2word(83,104,111,119)
, bytes2word(46,68,97,116)
, bytes2word(97,46,70,105)
, bytes2word(120,101,100,46)
, bytes2word(70,105,120,101)
, bytes2word(100,46,115,104)
, bytes2word(111,119,115,84)
, bytes2word(121,112,101,0)
,	/* PS_v1706: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46div_39)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v1705: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46div_39)
, useLabel(PC_Prelude_46toRational)
,	/* PS_v1703: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46div_39)
, useLabel(PC_Data_46Fixed_46div_39)
,	/* PS_v1708: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46div_39)
, useLabel(PC_Prelude_46RealFrac_46Ratio_46Ratio_46floor)
,	/* PS_v1707: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46div_39)
, useLabel(PC_Prelude_46Fractional_46Ratio_46Ratio_46_47)
,	/* PS_v1732: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46divMod_39)
, useLabel(PC_NHC_46Internal_46_95apply2)
,	/* PS_v1727: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46divMod_39)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v1731: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46divMod_39)
, useLabel(PC_Prelude_46fromIntegral)
,	/* PS_v1733: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46divMod_39)
, useLabel(PC_Prelude_462)
,	/* PS_v1729: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46divMod_39)
, useLabel(PC_Prelude_46_45)
,	/* PS_v1730: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46divMod_39)
, useLabel(PC_Prelude_46_42)
,	/* PS_v1724: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46divMod_39)
, useLabel(PC_Data_46Fixed_46divMod_39)
,	/* PS_v1726: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46divMod_39)
, useLabel(PC_Data_46Fixed_46Prelude_46182_46f)
,	/* PS_v1728: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46divMod_39)
, useLabel(PC_Prelude_46Real_46Prelude_46Num)
,	/* PS_v1717: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46mod_39)
, useLabel(PC_NHC_46Internal_46_95apply2)
,	/* PS_v1716: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46mod_39)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v1718: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46mod_39)
, useLabel(PC_Prelude_46_45)
,	/* PS_v1713: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46mod_39)
, useLabel(PC_Prelude_46_42)
,	/* PS_v1714: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46mod_39)
, useLabel(PC_Prelude_46fromInteger)
,	/* PS_v1710: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46mod_39)
, useLabel(PC_Data_46Fixed_46mod_39)
,	/* PS_v1715: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46mod_39)
, useLabel(PC_Data_46Fixed_46Prelude_46185_46f)
,	/* PS_v1712: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46mod_39)
, useLabel(PC_Prelude_46Real_46Prelude_46Num)
,	/* PS_v1783: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46resolution)
, useLabel(PC_Data_46Fixed_46resolution)
,	/* PS_v1414: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46fixedResolution)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v1415: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46fixedResolution)
, useLabel(PC_Data_46Fixed_46resolution)
,	/* PS_v1411: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46fixedResolution)
, useLabel(PC_Data_46Fixed_46fixedResolution)
,	/* PS_v1413: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46fixedResolution)
, useLabel(PC_Data_46Fixed_46Prelude_46188_46uf)
,	/* PS_v1584: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46withType)
, useLabel(PC_Data_46Fixed_46withType)
,	/* PS_v1590: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46withResolution)
, useLabel(PC_Prelude_46_46)
,	/* PS_v1589: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46withResolution)
, useLabel(PC_Data_46Fixed_46resolution)
,	/* PS_v1591: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46withResolution)
, useLabel(PC_Data_46Fixed_46withType)
,	/* PS_v1587: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46withResolution)
, useLabel(PC_Data_46Fixed_46withResolution)
,	/* PS_v1444: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46chopZeros)
, useLabel(PC_NHC_46Internal_46_95eqInteger)
,	/* PS_v1442: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46chopZeros)
, useLabel(PC_Data_46Fixed_46chopZeros)
,	/* PS_v1447: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46chopZeros)
, useLabel(PC_Prelude_46Eq_46Prelude_46Integer_46_61_61)
,	/* PS_v1446: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46chopZeros)
, useLabel(PC_Prelude_46Integral_46Prelude_46Integer_46mod)
,	/* PS_v1448: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46chopZeros)
, useLabel(PC_Prelude_46Integral_46Prelude_46Integer_46div)
,	/* PS_v1449: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46chopZeros)
, useLabel(PC_Prelude_46Show_46Prelude_46Integer_46show)
,	/* PS_v1445: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46chopZeros)
, useLabel(PC_LAMBDA1368)
,	/* PS_v1465: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showIntegerZeros)
, useLabel(PC_NHC_46Internal_46_95eqInteger)
,	/* PS_v1472: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showIntegerZeros)
, useLabel(PC_Prelude_46_43_43)
,	/* PS_v1471: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showIntegerZeros)
, useLabel(PC_Prelude_46replicate)
,	/* PS_v1469: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showIntegerZeros)
, useLabel(PC_Prelude_46length)
,	/* PS_v1462: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showIntegerZeros)
, useLabel(PC_Data_46Fixed_46showIntegerZeros)
,	/* PS_v1467: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showIntegerZeros)
, useLabel(PC_Prelude_46Show_46Prelude_46Integer_46show)
,	/* PS_v1470: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showIntegerZeros)
, useLabel(PC_Prelude_46Num_46Prelude_46Int_46_45)
,	/* PS_v1466: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showIntegerZeros)
, useLabel(PC_LAMBDA1369)
,	/* PS_v1468: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showIntegerZeros)
, useLabel(PC_LAMBDA1370)
,	/* PS_v1428: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46withDot)
, useLabel(PC_Prelude_46_58)
,	/* PS_v1424: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46withDot)
, useLabel(PC_Data_46Fixed_46withDot)
,	/* PS_v1427: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46withDot)
, useLabel(PC_LAMBDA1367)
,	/* PS_v1493: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_NHC_46Internal_46_95apply2)
,	/* PS_v1500: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v1494: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Prelude_46_43_43)
,	/* PS_v1491: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Prelude_46asTypeOf)
,	/* PS_v1495: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Data_46Fixed_46fixedResolution)
,	/* PS_v1505: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Data_46Fixed_46showIntegerZeros)
,	/* PS_v1506: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Data_46Fixed_46withDot)
,	/* PS_v1487: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Data_46Fixed_46showFixed)
,	/* PS_v1504: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Data_46Fixed_46Prelude_46271_46digits)
,	/* PS_v1499: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Data_46Fixed_46Prelude_46272_46maxnum)
,	/* PS_v1502: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Prelude_46Integral_46Prelude_46Integer_46div)
,	/* PS_v1503: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Prelude_46Show_46Prelude_46Integer_46show)
,	/* PS_v1489: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Prelude_46Ord_46Prelude_46Integer_46_60)
,	/* PS_v1492: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46negate)
,	/* PS_v1496: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Prelude_46Integral_46Prelude_46Integer_46divMod)
,	/* PS_v1501: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46_42)
,	/* PS_v1490: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_LAMBDA1371)
,	/* PS_v1497: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_LAMBDA1372)
,	/* PS_v1498: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46showFixed)
, useLabel(PC_LAMBDA1373)
,	/* PS_v1737: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46182_46f)
, useLabel(PC_Data_46Fixed_46div_39)
,	/* PS_v1735: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46182_46f)
, useLabel(PC_Data_46Fixed_46Prelude_46182_46f)
,	/* PS_v1722: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46185_46f)
, useLabel(PC_Data_46Fixed_46div_39)
,	/* PS_v1720: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46185_46f)
, useLabel(PC_Data_46Fixed_46Prelude_46185_46f)
,	/* PS_v1697: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46_95_46resolution)
, useLabel(PC_NHC_46Internal_46_95noMethodError)
,	/* PS_v1694: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46_95_46resolution)
, useLabel(PC_Data_46Fixed_46_95_46resolution)
,	/* PS_v1696: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46_95_46resolution)
, useLabel(PC_LAMBDA1376)
,	/* PS_v1417: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46188_46uf)
, useLabel(PC_Data_46Fixed_46Prelude_46188_46uf)
,	/* PS_v1690: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46succ)
, useLabel(PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46succ)
,	/* PS_v1692: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46succ)
, useLabel(PC_Prelude_46Enum_46Prelude_46Integer_46succ)
,	/* PS_v1686: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46pred)
, useLabel(PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46pred)
,	/* PS_v1688: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46pred)
, useLabel(PC_Prelude_46Enum_46Prelude_46Integer_46pred)
,	/* PS_v1684: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46toEnum)
, useLabel(PC_Prelude_46_46)
,	/* PS_v1682: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46toEnum)
, useLabel(PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46toEnum)
,	/* PS_v1678: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46fromEnum)
, useLabel(PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46fromEnum)
,	/* PS_v1680: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46fromEnum)
, useLabel(PC_Prelude_46Enum_46Prelude_46Integer_46fromEnum)
,	/* PS_v1673: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom)
, useLabel(PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom)
,	/* PS_v1676: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom)
, useLabel(PC_Prelude_46Functor_46Prelude_46_91_93_46fmap)
,	/* PS_v1675: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFrom)
, useLabel(PC_Prelude_46Enum_46Prelude_46Integer_46enumFrom)
,	/* PS_v1668: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen)
, useLabel(PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen)
,	/* PS_v1671: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen)
, useLabel(PC_Prelude_46Functor_46Prelude_46_91_93_46fmap)
,	/* PS_v1670: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThen)
, useLabel(PC_Prelude_46Enum_46Prelude_46Integer_46enumFromThen)
,	/* PS_v1663: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo)
, useLabel(PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo)
,	/* PS_v1666: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo)
, useLabel(PC_Prelude_46Functor_46Prelude_46_91_93_46fmap)
,	/* PS_v1665: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromTo)
, useLabel(PC_Prelude_46Enum_46Prelude_46Integer_46enumFromTo)
,	/* PS_v1658: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo)
, useLabel(PC_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo)
,	/* PS_v1661: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo)
, useLabel(PC_Prelude_46Functor_46Prelude_46_91_93_46fmap)
,	/* PS_v1660: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed_46enumFromThenTo)
, useLabel(PC_Prelude_46Enum_46Prelude_46Integer_46enumFromThenTo)
,	/* PS_v1654: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_43)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_43)
,	/* PS_v1656: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_43)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46_43)
,	/* PS_v1650: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_45)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_45)
,	/* PS_v1652: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_45)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46_45)
,	/* PS_v1647: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_42)
, useLabel(PC_Data_46Fixed_46fixedResolution)
,	/* PS_v1644: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_42)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_42)
,	/* PS_v1648: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_42)
, useLabel(PC_Prelude_46Integral_46Prelude_46Integer_46div)
,	/* PS_v1646: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46_42)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46_42)
,	/* PS_v1640: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46negate)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46negate)
,	/* PS_v1642: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46negate)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46negate)
,	/* PS_v1636: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46abs)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46abs)
,	/* PS_v1638: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46abs)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46abs)
,	/* PS_v1631: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46signum)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46signum)
,	/* PS_v1634: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46signum)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger)
,	/* PS_v1633: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46signum)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46signum)
,	/* PS_v1625: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger)
, useLabel(PC_Data_46Fixed_46withResolution)
,	/* PS_v1622: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger)
,	/* PS_v1624: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger)
, useLabel(PC_LAMBDA1375)
,	/* PS_v1619: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
, useLabel(PC_Data_46Fixed_46fixedResolution)
,	/* PS_v1616: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
, useLabel(PC_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
,	/* PS_v1618: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
, useLabel(PC_Prelude_46Real_46Prelude_46Integer_46toRational)
,	/* PS_v1620: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
, useLabel(PC_Prelude_46Fractional_46Ratio_46Ratio_46_47)
,	/* PS_v1612: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47)
, useLabel(PC_Data_46Fixed_46fixedResolution)
,	/* PS_v1610: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47)
, useLabel(PC_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47)
,	/* PS_v1614: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47)
, useLabel(PC_Prelude_46Integral_46Prelude_46Integer_46div)
,	/* PS_v1613: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46_42)
,	/* PS_v1606: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip)
, useLabel(PC_Data_46Fixed_46fixedResolution)
,	/* PS_v1604: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip)
, useLabel(PC_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip)
,	/* PS_v1608: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip)
, useLabel(PC_Prelude_46Integral_46Prelude_46Integer_46div)
,	/* PS_v1607: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46_42)
,	/* PS_v1596: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational)
, useLabel(PC_Data_46Fixed_46withResolution)
,	/* PS_v1593: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational)
, useLabel(PC_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational)
,	/* PS_v1595: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational)
, useLabel(PC_LAMBDA1374)
,	/* PS_v1574: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v1576: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction)
, useLabel(PC_Prelude_46fromIntegral)
,	/* PS_v1578: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction)
, useLabel(PC_Prelude_462)
,	/* PS_v1571: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction)
,	/* PS_v1573: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction)
, useLabel(PC_Data_46Fixed_46Prelude_46245_46i)
,	/* PS_v1577: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_45)
,	/* PS_v1575: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed)
,	/* PS_v1580: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46245_46i)
, useLabel(PC_Data_46Fixed_46Prelude_46245_46i)
,	/* PS_v1582: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46245_46i)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate)
,	/* PS_v1566: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate)
,	/* PS_v1568: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate)
, useLabel(PC_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
,	/* PS_v1569: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate)
, useLabel(PC_Prelude_46RealFrac_46Ratio_46Ratio_46truncate)
,	/* PS_v1561: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round)
,	/* PS_v1563: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round)
, useLabel(PC_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
,	/* PS_v1564: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round)
, useLabel(PC_Prelude_46RealFrac_46Ratio_46Ratio_46round)
,	/* PS_v1556: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling)
,	/* PS_v1558: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling)
, useLabel(PC_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
,	/* PS_v1559: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling)
, useLabel(PC_Prelude_46RealFrac_46Ratio_46Ratio_46ceiling)
,	/* PS_v1551: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor)
,	/* PS_v1554: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor)
, useLabel(PC_Prelude_46RealFrac_46Ratio_46Ratio_46floor)
,	/* PS_v1553: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor)
, useLabel(PC_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
,	/* PS_v1515: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46271_46digits)
, useLabel(PC_Data_46Fixed_46Prelude_46271_46digits)
,	/* PS_v1519: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46271_46digits)
, useLabel(PC_Prelude_46RealFrac_46Prelude_46Double_46ceiling)
,	/* PS_v1518: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46271_46digits)
, useLabel(PC_Prelude_46Floating_46Prelude_46Double_46logBase)
,	/* PS_v1517: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46271_46digits)
, useLabel(PC_Prelude_46Num_46Prelude_46Double_46fromInteger)
,	/* PS_v1511: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46272_46maxnum)
, useLabel(PC_NHC_46Internal_46_95apply1)
,	/* PS_v1513: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46272_46maxnum)
, useLabel(PC_Prelude_46_94)
,	/* PS_v1510: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46272_46maxnum)
, useLabel(PC_Prelude_46fromInteger)
,	/* PS_v1512: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46272_46maxnum)
, useLabel(PC_Data_46Fixed_46Prelude_46271_46digits)
,	/* PS_v1508: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46Prelude_46272_46maxnum)
, useLabel(PC_Data_46Fixed_46Prelude_46272_46maxnum)
,	/* PS_v1533: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46show)
, useLabel(PC_Prelude_46False)
,	/* PS_v1534: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46show)
, useLabel(PC_Data_46Fixed_46showFixed)
,	/* PS_v1531: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46show)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed_46show)
,	/* PS_v1408: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6_46resolution)
, useLabel(PC_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6_46resolution)
,	/* PS_v1405: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12_46resolution)
, useLabel(PC_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12_46resolution)
,	/* PS_v1549: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec)
, useLabel(PC_Prelude_46_95_46showsPrec)
,	/* PS_v1546: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec)
,	/* PS_v1548: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed)
,	/* PS_v1544: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showList)
, useLabel(PC_Prelude_46_95_46showList)
,	/* PS_v1541: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showList)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed_46showList)
,	/* PS_v1543: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showList)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed)
,	/* PS_v1539: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType)
, useLabel(PC_Prelude_46_95_46showsType)
,	/* PS_v1536: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType)
,	/* PS_v1538: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed)
,	/* PS_v1767: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Eq_46Data_46Fixed_46Fixed_46_61_61)
, useLabel(PC_Prelude_46Eq_46Data_46Fixed_46Fixed_46_61_61)
,	/* PS_v1769: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Eq_46Data_46Fixed_46Fixed_46_61_61)
, useLabel(PC_Prelude_46Eq_46Prelude_46Integer_46_61_61)
,	/* PS_v1773: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Eq_46Data_46Fixed_46Fixed_46_47_61)
, useLabel(PC_Prelude_46_95_46_47_61)
,	/* PS_v1771: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Eq_46Data_46Fixed_46Fixed_46_47_61)
, useLabel(PC_Prelude_46Eq_46Data_46Fixed_46Fixed_46_47_61)
,	/* PS_v1743: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60_61)
, useLabel(PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60_61)
,	/* PS_v1745: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60_61)
, useLabel(PC_Prelude_46Ord_46Prelude_46Integer_46_60_61)
,	/* PS_v1739: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46compare)
, useLabel(PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46compare)
,	/* PS_v1741: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46compare)
, useLabel(PC_Prelude_46Ord_46Prelude_46Integer_46compare)
,	/* PS_v1765: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60)
, useLabel(PC_Prelude_46_95_46_60)
,	/* PS_v1763: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60)
, useLabel(PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46_60)
,	/* PS_v1761: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62_61)
, useLabel(PC_Prelude_46_95_46_62_61)
,	/* PS_v1759: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62_61)
, useLabel(PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62_61)
,	/* PS_v1757: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62)
, useLabel(PC_Prelude_46_95_46_62)
,	/* PS_v1755: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62)
, useLabel(PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46_62)
,	/* PS_v1753: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46max)
, useLabel(PC_Prelude_46_95_46max)
,	/* PS_v1751: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46max)
, useLabel(PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46max)
,	/* PS_v1749: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46min)
, useLabel(PC_Prelude_46_95_46min)
,	/* PS_v1747: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed_46min)
, useLabel(PC_Prelude_46Ord_46Data_46Fixed_46Fixed_46min)
,	/* PS_v1832: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed_46show)
,	/* PS_v1829: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed_46showsPrec)
,	/* PS_v1831: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed_46showList)
,	/* PS_v1830: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed_46showsType)
,	/* PS_v1827: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed)
,	/* PS_v1833: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Show_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_464)
,	/* PS_v1794: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_43)
,	/* PS_v1795: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_45)
,	/* PS_v1793: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46_42)
,	/* PS_v1796: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46negate)
,	/* PS_v1799: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46abs)
,	/* PS_v1797: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46signum)
,	/* PS_v1798: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed_46fromInteger)
,	/* PS_v1792: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Show_46Data_46Fixed_46Fixed)
,	/* PS_v1790: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed)
,	/* PS_v1800: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Num_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_469)
,	/* PS_v1779: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Ord_46Data_46Fixed_46Fixed)
,	/* PS_v1781: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Ord_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_468)
,	/* PS_v1775: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Eq_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Eq_46Data_46Fixed_46Fixed)
,	/* PS_v1777: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Eq_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_462)
,	/* PS_v1788: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_468)
,	/* PS_v1786: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Enum_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Enum_46Data_46Fixed_46Fixed)
,	/* PS_v1805: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Real_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Real_46Data_46Fixed_46Fixed_46toRational)
,	/* PS_v1804: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Real_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed)
,	/* PS_v1802: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Real_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Real_46Data_46Fixed_46Fixed)
,	/* PS_v1806: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Real_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_463)
,	/* PS_v1811: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Fractional_46Data_46Fixed_46Fixed_46_47)
,	/* PS_v1813: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Fractional_46Data_46Fixed_46Fixed_46recip)
,	/* PS_v1812: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Fractional_46Data_46Fixed_46Fixed_46fromRational)
,	/* PS_v1810: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Num_46Data_46Fixed_46Fixed)
,	/* PS_v1808: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Fractional_46Data_46Fixed_46Fixed)
,	/* PS_v1814: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46Fractional_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_464)
,	/* PS_v1823: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46properFraction)
,	/* PS_v1821: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46truncate)
,	/* PS_v1820: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46round)
,	/* PS_v1822: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46ceiling)
,	/* PS_v1824: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed_46floor)
,	/* PS_v1818: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Real_46Data_46Fixed_46Fixed)
,	/* PS_v1819: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46Fractional_46Data_46Fixed_46Fixed)
,	/* PS_v1816: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
,	/* PS_v1825: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Prelude_46RealFrac_46Data_46Fixed_46Fixed)
, useLabel(PC_Prelude_467)
,	/* PS_v1837: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6)
, useLabel(PC_Prelude_461)
,	/* PS_v1835: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6)
, useLabel(PC_Data_46Fixed_46HasResolution_46Data_46Fixed_46E6)
,	/* PS_v1841: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12)
, useLabel(PC_Prelude_461)
,	/* PS_v1839: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12)
, useLabel(PC_Data_46Fixed_46HasResolution_46Data_46Fixed_46E12)
,	/* PS_v1430: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1367)
, useLabel(PC_LAMBDA1367)
,	/* PS_v1451: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1368)
, useLabel(PC_LAMBDA1368)
,	/* PS_v1480: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1369)
, useLabel(PC_LAMBDA1369)
,	/* PS_v1478: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1370)
, useLabel(PC_Data_46Fixed_46chopZeros)
,	/* PS_v1476: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1370)
, useLabel(PC_LAMBDA1370)
,	/* PS_v1527: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1371)
, useLabel(PC_LAMBDA1371)
,	/* PS_v1524: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1372)
, useLabel(PC_LAMBDA1372)
,	/* PS_v1521: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1373)
, useLabel(PC_LAMBDA1373)
,	/* PS_v1602: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1374)
, useLabel(PC_Prelude_46RealFrac_46Ratio_46Ratio_46floor)
,	/* PS_v1601: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1374)
, useLabel(PC_Prelude_46Num_46Ratio_46Ratio_46_42)
,	/* PS_v1600: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1374)
, useLabel(PC_Prelude_46Real_46Prelude_46Integer_46toRational)
,	/* PS_v1598: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1374)
, useLabel(PC_LAMBDA1374)
,	/* PS_v1629: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1375)
, useLabel(PC_Prelude_46Num_46Prelude_46Integer_46_42)
,	/* PS_v1627: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1375)
, useLabel(PC_LAMBDA1375)
,	/* PS_v1699: (byte 0) */
  useLabel(PM_Data_46Fixed)
, useLabel(PP_LAMBDA1376)
, useLabel(PC_LAMBDA1376)
,};
