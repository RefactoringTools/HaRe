#include "newmacros.h"
#include "runtime.h"

#define C0_Data_46Sequence_46Empty	((void*)startLabel+4)
#define C0_Data_46Sequence_46Nothing2	((void*)startLabel+8)
#define FN_Data_46Sequence_46reverseNode	((void*)startLabel+32)
#define v9737	((void*)startLabel+42)
#define v9738	((void*)startLabel+61)
#define CT_v9740	((void*)startLabel+100)
#define F0_Data_46Sequence_46reverseNode	((void*)startLabel+108)
#define FN_Data_46Sequence_46reverseDigit	((void*)startLabel+128)
#define v9742	((void*)startLabel+142)
#define v9743	((void*)startLabel+155)
#define v9744	((void*)startLabel+174)
#define v9745	((void*)startLabel+198)
#define CT_v9747	((void*)startLabel+252)
#define F0_Data_46Sequence_46reverseDigit	((void*)startLabel+260)
#define FN_Data_46Sequence_46reverseTree	((void*)startLabel+280)
#define v9749	((void*)startLabel+292)
#define v9750	((void*)startLabel+297)
#define v9751	((void*)startLabel+310)
#define CT_v9753	((void*)startLabel+360)
#define F0_Data_46Sequence_46reverseTree	((void*)startLabel+368)
#define CT_v9754	((void*)startLabel+408)
#define FN_Data_46Sequence_46deep	((void*)startLabel+444)
#define CT_v9755	((void*)startLabel+496)
#define F0_Data_46Sequence_46deep	((void*)startLabel+504)
#define FN_Data_46Sequence_46node3	((void*)startLabel+540)
#define CT_v9756	((void*)startLabel+600)
#define F0_Data_46Sequence_46node3	((void*)startLabel+608)
#define FN_Data_46Sequence_46snocTree	((void*)startLabel+636)
#define v9758	((void*)startLabel+648)
#define v9759	((void*)startLabel+655)
#define v9760	((void*)startLabel+677)
#define v9762	((void*)startLabel+696)
#define v9763	((void*)startLabel+729)
#define v9764	((void*)startLabel+763)
#define v9765	((void*)startLabel+799)
#define CT_v9768	((void*)startLabel+864)
#define F0_Data_46Sequence_46snocTree	((void*)startLabel+872)
#define FN_LAMBDA9570	((void*)startLabel+924)
#define CT_v9769	((void*)startLabel+984)
#define F0_LAMBDA9570	((void*)startLabel+992)
#define CT_v9770	((void*)startLabel+1044)
#define CT_v9771	((void*)startLabel+1092)
#define CT_v9772	((void*)startLabel+1124)
#define FN_Data_46Sequence_46splitDigit	((void*)startLabel+1160)
#define v9776	((void*)startLabel+1174)
#define v9777	((void*)startLabel+1195)
#define v9778	((void*)startLabel+1238)
#define v9780	((void*)startLabel+1263)
#define v9782	((void*)startLabel+1268)
#define v9783	((void*)startLabel+1331)
#define v9785	((void*)startLabel+1364)
#define v9787	((void*)startLabel+1394)
#define v9789	((void*)startLabel+1399)
#define v9790	((void*)startLabel+1481)
#define v9792	((void*)startLabel+1517)
#define v9794	((void*)startLabel+1553)
#define v9796	((void*)startLabel+1585)
#define v9773	((void*)startLabel+1590)
#define CT_v9799	((void*)startLabel+1628)
#define F0_Data_46Sequence_46splitDigit	((void*)startLabel+1636)
#define FN_LAMBDA9571	((void*)startLabel+1676)
#define CT_v9801	((void*)startLabel+1696)
#define CF_LAMBDA9571	((void*)startLabel+1704)
#define FN_Data_46Sequence_46splitNode	((void*)startLabel+1720)
#define v9805	((void*)startLabel+1730)
#define v9806	((void*)startLabel+1774)
#define v9808	((void*)startLabel+1800)
#define v9810	((void*)startLabel+1805)
#define v9811	((void*)startLabel+1868)
#define v9813	((void*)startLabel+1901)
#define v9815	((void*)startLabel+1930)
#define v9802	((void*)startLabel+1935)
#define CT_v9818	((void*)startLabel+1972)
#define F0_Data_46Sequence_46splitNode	((void*)startLabel+1980)
#define FN_LAMBDA9572	((void*)startLabel+2016)
#define CT_v9820	((void*)startLabel+2036)
#define CF_LAMBDA9572	((void*)startLabel+2044)
#define FN_Data_46Sequence_46digitToTree	((void*)startLabel+2060)
#define v9822	((void*)startLabel+2074)
#define v9823	((void*)startLabel+2081)
#define v9824	((void*)startLabel+2102)
#define v9825	((void*)startLabel+2124)
#define CT_v9827	((void*)startLabel+2172)
#define F0_Data_46Sequence_46digitToTree	((void*)startLabel+2180)
#define FN_Data_46Sequence_46nodeToDigit	((void*)startLabel+2196)
#define v9829	((void*)startLabel+2206)
#define v9830	((void*)startLabel+2215)
#define CT_v9832	((void*)startLabel+2240)
#define F0_Data_46Sequence_46nodeToDigit	((void*)startLabel+2248)
#define FN_Data_46Sequence_46viewRTree	((void*)startLabel+2264)
#define v9834	((void*)startLabel+2276)
#define v9835	((void*)startLabel+2281)
#define v9836	((void*)startLabel+2292)
#define v9838	((void*)startLabel+2310)
#define v9839	((void*)startLabel+2328)
#define v9840	((void*)startLabel+2348)
#define v9841	((void*)startLabel+2371)
#define CT_v9844	((void*)startLabel+2412)
#define F0_Data_46Sequence_46viewRTree	((void*)startLabel+2420)
#define FN_LAMBDA9576	((void*)startLabel+2464)
#define CT_v9845	((void*)startLabel+2512)
#define F0_LAMBDA9576	((void*)startLabel+2520)
#define FN_LAMBDA9575	((void*)startLabel+2556)
#define CT_v9846	((void*)startLabel+2600)
#define F0_LAMBDA9575	((void*)startLabel+2608)
#define FN_LAMBDA9574	((void*)startLabel+2644)
#define CT_v9847	((void*)startLabel+2688)
#define F0_LAMBDA9574	((void*)startLabel+2696)
#define FN_LAMBDA9573	((void*)startLabel+2728)
#define v9849	((void*)startLabel+2744)
#define v9850	((void*)startLabel+2750)
#define CT_v9852	((void*)startLabel+2796)
#define F0_LAMBDA9573	((void*)startLabel+2804)
#define FN_Data_46Sequence_46deepR	((void*)startLabel+2852)
#define v9854	((void*)startLabel+2864)
#define v9856	((void*)startLabel+2878)
#define v9857	((void*)startLabel+2884)
#define v9858	((void*)startLabel+2899)
#define CT_v9861	((void*)startLabel+2916)
#define F0_Data_46Sequence_46deepR	((void*)startLabel+2924)
#define FN_Data_46Sequence_46viewLTree	((void*)startLabel+2960)
#define v9863	((void*)startLabel+2972)
#define v9864	((void*)startLabel+2977)
#define v9865	((void*)startLabel+2988)
#define v9867	((void*)startLabel+3006)
#define v9868	((void*)startLabel+3025)
#define v9869	((void*)startLabel+3045)
#define v9870	((void*)startLabel+3067)
#define CT_v9873	((void*)startLabel+3108)
#define F0_Data_46Sequence_46viewLTree	((void*)startLabel+3116)
#define FN_LAMBDA9580	((void*)startLabel+3160)
#define CT_v9874	((void*)startLabel+3208)
#define F0_LAMBDA9580	((void*)startLabel+3216)
#define FN_LAMBDA9579	((void*)startLabel+3252)
#define CT_v9875	((void*)startLabel+3296)
#define F0_LAMBDA9579	((void*)startLabel+3304)
#define FN_LAMBDA9578	((void*)startLabel+3340)
#define CT_v9876	((void*)startLabel+3384)
#define F0_LAMBDA9578	((void*)startLabel+3392)
#define FN_LAMBDA9577	((void*)startLabel+3424)
#define v9878	((void*)startLabel+3440)
#define v9879	((void*)startLabel+3446)
#define CT_v9881	((void*)startLabel+3492)
#define F0_LAMBDA9577	((void*)startLabel+3500)
#define FN_Data_46Sequence_46deepL	((void*)startLabel+3548)
#define v9883	((void*)startLabel+3558)
#define v9885	((void*)startLabel+3572)
#define v9886	((void*)startLabel+3578)
#define v9887	((void*)startLabel+3595)
#define CT_v9890	((void*)startLabel+3612)
#define F0_Data_46Sequence_46deepL	((void*)startLabel+3620)
#define FN_Data_46Sequence_46splitTree	((void*)startLabel+3656)
#define v9894	((void*)startLabel+3668)
#define v9895	((void*)startLabel+3675)
#define v9896	((void*)startLabel+3696)
#define v9897	((void*)startLabel+3779)
#define v9901	((void*)startLabel+3854)
#define v9907	((void*)startLabel+3913)
#define v9891	((void*)startLabel+3918)
#define CT_v9916	((void*)startLabel+3940)
#define F0_Data_46Sequence_46splitTree	((void*)startLabel+3948)
#define FN_LAMBDA9582	((void*)startLabel+4032)
#define CT_v9918	((void*)startLabel+4052)
#define CF_LAMBDA9582	((void*)startLabel+4060)
#define FN_LAMBDA9581	((void*)startLabel+4072)
#define CT_v9920	((void*)startLabel+4092)
#define CF_LAMBDA9581	((void*)startLabel+4100)
#define FN_Data_46Sequence_46consTree	((void*)startLabel+4116)
#define v9922	((void*)startLabel+4128)
#define v9923	((void*)startLabel+4135)
#define v9924	((void*)startLabel+4157)
#define v9926	((void*)startLabel+4174)
#define v9927	((void*)startLabel+4207)
#define v9928	((void*)startLabel+4241)
#define v9929	((void*)startLabel+4277)
#define CT_v9932	((void*)startLabel+4344)
#define F0_Data_46Sequence_46consTree	((void*)startLabel+4352)
#define FN_LAMBDA9583	((void*)startLabel+4404)
#define CT_v9933	((void*)startLabel+4464)
#define F0_LAMBDA9583	((void*)startLabel+4472)
#define FN_Data_46Sequence_46split	((void*)startLabel+4512)
#define v9942	((void*)startLabel+4524)
#define v9937	((void*)startLabel+4528)
#define v9934	((void*)startLabel+4546)
#define v9938	((void*)startLabel+4598)
#define v9940	((void*)startLabel+4619)
#define CT_v9943	((void*)startLabel+4640)
#define F0_Data_46Sequence_46split	((void*)startLabel+4648)
#define FN_LAMBDA9587	((void*)startLabel+4704)
#define CT_v9945	((void*)startLabel+4724)
#define CF_LAMBDA9587	((void*)startLabel+4732)
#define FN_LAMBDA9586	((void*)startLabel+4744)
#define CT_v9946	((void*)startLabel+4756)
#define F0_LAMBDA9586	((void*)startLabel+4764)
#define FN_LAMBDA9585	((void*)startLabel+4776)
#define CT_v9947	((void*)startLabel+4788)
#define F0_LAMBDA9585	((void*)startLabel+4796)
#define FN_LAMBDA9584	((void*)startLabel+4808)
#define CT_v9948	((void*)startLabel+4820)
#define F0_LAMBDA9584	((void*)startLabel+4828)
#define CT_v9949	((void*)startLabel+4880)
#define FN_LAMBDA9589	((void*)startLabel+4912)
#define CT_v9950	((void*)startLabel+4924)
#define F0_LAMBDA9589	((void*)startLabel+4932)
#define FN_LAMBDA9588	((void*)startLabel+4944)
#define CT_v9951	((void*)startLabel+4956)
#define F0_LAMBDA9588	((void*)startLabel+4964)
#define CT_v9952	((void*)startLabel+4992)
#define CT_v9953	((void*)startLabel+5040)
#define FN_Data_46Sequence_46adjustDigit	((void*)startLabel+5080)
#define v9957	((void*)startLabel+5096)
#define v9958	((void*)startLabel+5110)
#define v9959	((void*)startLabel+5147)
#define v9961	((void*)startLabel+5175)
#define v9963	((void*)startLabel+5180)
#define v9964	((void*)startLabel+5236)
#define v9966	((void*)startLabel+5266)
#define v9968	((void*)startLabel+5295)
#define v9970	((void*)startLabel+5300)
#define v9971	((void*)startLabel+5376)
#define v9973	((void*)startLabel+5410)
#define v9975	((void*)startLabel+5443)
#define v9977	((void*)startLabel+5475)
#define v9954	((void*)startLabel+5480)
#define CT_v9980	((void*)startLabel+5512)
#define F0_Data_46Sequence_46adjustDigit	((void*)startLabel+5520)
#define FN_LAMBDA9590	((void*)startLabel+5564)
#define CT_v9982	((void*)startLabel+5584)
#define CF_LAMBDA9590	((void*)startLabel+5592)
#define FN_Data_46Sequence_46adjustNode	((void*)startLabel+5612)
#define v9986	((void*)startLabel+5624)
#define v9987	((void*)startLabel+5665)
#define v9989	((void*)startLabel+5695)
#define v9991	((void*)startLabel+5700)
#define v9992	((void*)startLabel+5760)
#define v9994	((void*)startLabel+5793)
#define v9996	((void*)startLabel+5825)
#define v9983	((void*)startLabel+5830)
#define CT_v9999	((void*)startLabel+5852)
#define F0_Data_46Sequence_46adjustNode	((void*)startLabel+5860)
#define FN_LAMBDA9591	((void*)startLabel+5904)
#define CT_v10001	((void*)startLabel+5924)
#define CF_LAMBDA9591	((void*)startLabel+5932)
#define FN_Data_46Sequence_46adjustTree	((void*)startLabel+5952)
#define v10005	((void*)startLabel+5966)
#define v10006	((void*)startLabel+5973)
#define v10007	((void*)startLabel+5987)
#define v10008	((void*)startLabel+6040)
#define v10010	((void*)startLabel+6081)
#define v10012	((void*)startLabel+6115)
#define v10002	((void*)startLabel+6120)
#define CT_v10015	((void*)startLabel+6144)
#define F0_Data_46Sequence_46adjustTree	((void*)startLabel+6152)
#define FN_LAMBDA9593	((void*)startLabel+6220)
#define CT_v10017	((void*)startLabel+6240)
#define CF_LAMBDA9593	((void*)startLabel+6248)
#define FN_LAMBDA9592	((void*)startLabel+6260)
#define CT_v10019	((void*)startLabel+6280)
#define CF_LAMBDA9592	((void*)startLabel+6288)
#define v10020	((void*)startLabel+6349)
#define v10022	((void*)startLabel+6360)
#define CT_v10024	((void*)startLabel+6376)
#define FN_LAMBDA9594	((void*)startLabel+6440)
#define CT_v10026	((void*)startLabel+6460)
#define CF_LAMBDA9594	((void*)startLabel+6468)
#define CT_v10027	((void*)startLabel+6500)
#define FN_Data_46Sequence_46lookupDigit	((void*)startLabel+6532)
#define v10031	((void*)startLabel+6546)
#define v10032	((void*)startLabel+6555)
#define v10033	((void*)startLabel+6587)
#define v10035	((void*)startLabel+6608)
#define v10037	((void*)startLabel+6613)
#define v10038	((void*)startLabel+6662)
#define v10040	((void*)startLabel+6684)
#define v10042	((void*)startLabel+6705)
#define v10044	((void*)startLabel+6710)
#define v10045	((void*)startLabel+6776)
#define v10047	((void*)startLabel+6799)
#define v10049	((void*)startLabel+6821)
#define v10051	((void*)startLabel+6842)
#define v10028	((void*)startLabel+6847)
#define CT_v10054	((void*)startLabel+6868)
#define F0_Data_46Sequence_46lookupDigit	((void*)startLabel+6876)
#define FN_LAMBDA9595	((void*)startLabel+6916)
#define CT_v10056	((void*)startLabel+6936)
#define CF_LAMBDA9595	((void*)startLabel+6944)
#define FN_Data_46Sequence_46lookupNode	((void*)startLabel+6960)
#define v10060	((void*)startLabel+6970)
#define v10061	((void*)startLabel+7003)
#define v10063	((void*)startLabel+7024)
#define v10065	((void*)startLabel+7029)
#define v10066	((void*)startLabel+7079)
#define v10068	((void*)startLabel+7101)
#define v10070	((void*)startLabel+7122)
#define v10057	((void*)startLabel+7127)
#define CT_v10073	((void*)startLabel+7148)
#define F0_Data_46Sequence_46lookupNode	((void*)startLabel+7156)
#define FN_LAMBDA9596	((void*)startLabel+7196)
#define CT_v10075	((void*)startLabel+7216)
#define CF_LAMBDA9596	((void*)startLabel+7224)
#define FN_Data_46Sequence_46lookupTree	((void*)startLabel+7240)
#define v10079	((void*)startLabel+7252)
#define v10080	((void*)startLabel+7259)
#define v10081	((void*)startLabel+7268)
#define v10082	((void*)startLabel+7308)
#define v10084	((void*)startLabel+7343)
#define v10088	((void*)startLabel+7366)
#define v10076	((void*)startLabel+7371)
#define CT_v10092	((void*)startLabel+7392)
#define F0_Data_46Sequence_46lookupTree	((void*)startLabel+7400)
#define FN_LAMBDA9598	((void*)startLabel+7464)
#define CT_v10094	((void*)startLabel+7484)
#define CF_LAMBDA9598	((void*)startLabel+7492)
#define FN_LAMBDA9597	((void*)startLabel+7504)
#define CT_v10096	((void*)startLabel+7524)
#define CF_LAMBDA9597	((void*)startLabel+7532)
#define v10097	((void*)startLabel+7590)
#define v10101	((void*)startLabel+7607)
#define CT_v10104	((void*)startLabel+7620)
#define FN_LAMBDA9600	((void*)startLabel+7684)
#define CT_v10106	((void*)startLabel+7704)
#define CF_LAMBDA9600	((void*)startLabel+7712)
#define FN_LAMBDA9599	((void*)startLabel+7724)
#define CT_v10108	((void*)startLabel+7744)
#define CF_LAMBDA9599	((void*)startLabel+7752)
#define v10110	((void*)startLabel+7780)
#define v10111	((void*)startLabel+7785)
#define CT_v10113	((void*)startLabel+7808)
#define v10115	((void*)startLabel+7850)
#define v10116	((void*)startLabel+7862)
#define CT_v10118	((void*)startLabel+7924)
#define FN_LAMBDA9601	((void*)startLabel+7980)
#define CT_v10119	((void*)startLabel+8004)
#define F0_LAMBDA9601	((void*)startLabel+8012)
#define CT_v10120	((void*)startLabel+8040)
#define CT_v10121	((void*)startLabel+8088)
#define CT_v10122	((void*)startLabel+8132)
#define v10124	((void*)startLabel+8174)
#define v10125	((void*)startLabel+8181)
#define CT_v10127	((void*)startLabel+8196)
#define FN_LAMBDA9602	((void*)startLabel+8228)
#define CT_v10129	((void*)startLabel+8248)
#define CF_LAMBDA9602	((void*)startLabel+8256)
#define v10131	((void*)startLabel+8282)
#define v10132	((void*)startLabel+8285)
#define CT_v10134	((void*)startLabel+8316)
#define v10136	((void*)startLabel+8354)
#define v10137	((void*)startLabel+8357)
#define CT_v10139	((void*)startLabel+8380)
#define CT_v10140	((void*)startLabel+8424)
#define CT_v10141	((void*)startLabel+8472)
#define CT_v10142	((void*)startLabel+8516)
#define CT_v10143	((void*)startLabel+8568)
#define CT_v10144	((void*)startLabel+8612)
#define FN_Data_46Sequence_46viewRTc	((void*)startLabel+8640)
#define CT_v10145	((void*)startLabel+8652)
#define CF_Data_46Sequence_46viewRTc	((void*)startLabel+8660)
#define FN_LAMBDA9603	((void*)startLabel+8680)
#define CT_v10147	((void*)startLabel+8700)
#define CF_LAMBDA9603	((void*)startLabel+8708)
#define CT_v10148	((void*)startLabel+8744)
#define v10150	((void*)startLabel+8788)
#define v10151	((void*)startLabel+8793)
#define CT_v10153	((void*)startLabel+8816)
#define v10155	((void*)startLabel+8858)
#define v10156	((void*)startLabel+8870)
#define CT_v10158	((void*)startLabel+8932)
#define FN_LAMBDA9604	((void*)startLabel+8988)
#define CT_v10159	((void*)startLabel+9012)
#define F0_LAMBDA9604	((void*)startLabel+9020)
#define CT_v10160	((void*)startLabel+9048)
#define CT_v10161	((void*)startLabel+9096)
#define CT_v10162	((void*)startLabel+9140)
#define v10164	((void*)startLabel+9182)
#define v10165	((void*)startLabel+9189)
#define CT_v10167	((void*)startLabel+9204)
#define FN_LAMBDA9605	((void*)startLabel+9236)
#define CT_v10169	((void*)startLabel+9256)
#define CF_LAMBDA9605	((void*)startLabel+9264)
#define v10171	((void*)startLabel+9290)
#define v10172	((void*)startLabel+9293)
#define CT_v10174	((void*)startLabel+9316)
#define v10176	((void*)startLabel+9358)
#define v10177	((void*)startLabel+9361)
#define CT_v10179	((void*)startLabel+9392)
#define CT_v10180	((void*)startLabel+9432)
#define CT_v10181	((void*)startLabel+9480)
#define CT_v10182	((void*)startLabel+9524)
#define CT_v10183	((void*)startLabel+9576)
#define CT_v10184	((void*)startLabel+9620)
#define FN_Data_46Sequence_46viewLTc	((void*)startLabel+9648)
#define CT_v10185	((void*)startLabel+9660)
#define CF_Data_46Sequence_46viewLTc	((void*)startLabel+9668)
#define FN_LAMBDA9606	((void*)startLabel+9688)
#define CT_v10187	((void*)startLabel+9708)
#define CF_LAMBDA9606	((void*)startLabel+9716)
#define CT_v10188	((void*)startLabel+9752)
#define CT_v10189	((void*)startLabel+9792)
#define v10194	((void*)startLabel+9832)
#define v10193	((void*)startLabel+9836)
#define v10190	((void*)startLabel+9841)
#define CT_v10195	((void*)startLabel+9860)
#define FN_Data_46Sequence_46node2	((void*)startLabel+9884)
#define CT_v10196	((void*)startLabel+9928)
#define F0_Data_46Sequence_46node2	((void*)startLabel+9936)
#define FN_Data_46Sequence_46appendTree2	((void*)startLabel+9968)
#define v10221	((void*)startLabel+9980)
#define v10200	((void*)startLabel+9984)
#define v10197	((void*)startLabel+9998)
#define v10222	((void*)startLabel+10010)
#define v10204	((void*)startLabel+10014)
#define v10201	((void*)startLabel+10028)
#define v10223	((void*)startLabel+10038)
#define v10208	((void*)startLabel+10042)
#define v10205	((void*)startLabel+10062)
#define v10224	((void*)startLabel+10072)
#define v10212	((void*)startLabel+10076)
#define v10209	((void*)startLabel+10096)
#define v10225	((void*)startLabel+10106)
#define v10216	((void*)startLabel+10110)
#define v10226	((void*)startLabel+10122)
#define v10220	((void*)startLabel+10126)
#define v10217	((void*)startLabel+10177)
#define v10213	((void*)startLabel+10182)
#define CT_v10227	((void*)startLabel+10204)
#define F0_Data_46Sequence_46appendTree2	((void*)startLabel+10212)
#define FN_LAMBDA9607	((void*)startLabel+10256)
#define CT_v10229	((void*)startLabel+10276)
#define CF_LAMBDA9607	((void*)startLabel+10284)
#define FN_Data_46Sequence_46addDigits2	((void*)startLabel+10308)
#define v10231	((void*)startLabel+10322)
#define v10233	((void*)startLabel+10338)
#define v10234	((void*)startLabel+10362)
#define v10235	((void*)startLabel+10387)
#define v10236	((void*)startLabel+10415)
#define v10237	((void*)startLabel+10449)
#define v10239	((void*)startLabel+10466)
#define v10240	((void*)startLabel+10492)
#define v10241	((void*)startLabel+10521)
#define v10242	((void*)startLabel+10556)
#define v10243	((void*)startLabel+10594)
#define v10245	((void*)startLabel+10610)
#define v10246	((void*)startLabel+10638)
#define v10247	((void*)startLabel+10672)
#define v10248	((void*)startLabel+10709)
#define v10249	((void*)startLabel+10749)
#define v10251	((void*)startLabel+10766)
#define v10252	((void*)startLabel+10801)
#define v10253	((void*)startLabel+10838)
#define v10254	((void*)startLabel+10878)
#define CT_v10260	((void*)startLabel+10928)
#define F0_Data_46Sequence_46addDigits2	((void*)startLabel+10936)
#define FN_Data_46Sequence_46appendTree3	((void*)startLabel+10980)
#define v10285	((void*)startLabel+10992)
#define v10264	((void*)startLabel+10996)
#define v10261	((void*)startLabel+11016)
#define v10286	((void*)startLabel+11028)
#define v10268	((void*)startLabel+11032)
#define v10265	((void*)startLabel+11052)
#define v10287	((void*)startLabel+11062)
#define v10272	((void*)startLabel+11066)
#define v10269	((void*)startLabel+11092)
#define v10288	((void*)startLabel+11102)
#define v10276	((void*)startLabel+11106)
#define v10273	((void*)startLabel+11132)
#define v10289	((void*)startLabel+11142)
#define v10280	((void*)startLabel+11146)
#define v10290	((void*)startLabel+11158)
#define v10284	((void*)startLabel+11162)
#define v10281	((void*)startLabel+11225)
#define v10277	((void*)startLabel+11230)
#define CT_v10291	((void*)startLabel+11252)
#define F0_Data_46Sequence_46appendTree3	((void*)startLabel+11260)
#define FN_LAMBDA9608	((void*)startLabel+11304)
#define CT_v10293	((void*)startLabel+11324)
#define CF_LAMBDA9608	((void*)startLabel+11332)
#define FN_Data_46Sequence_46addDigits3	((void*)startLabel+11356)
#define v10295	((void*)startLabel+11370)
#define v10297	((void*)startLabel+11386)
#define v10298	((void*)startLabel+11412)
#define v10299	((void*)startLabel+11439)
#define v10300	((void*)startLabel+11472)
#define v10301	((void*)startLabel+11507)
#define v10303	((void*)startLabel+11524)
#define v10304	((void*)startLabel+11551)
#define v10305	((void*)startLabel+11584)
#define v10306	((void*)startLabel+11619)
#define v10307	((void*)startLabel+11656)
#define v10309	((void*)startLabel+11672)
#define v10310	((void*)startLabel+11705)
#define v10311	((void*)startLabel+11740)
#define v10312	((void*)startLabel+11777)
#define v10313	((void*)startLabel+11820)
#define v10315	((void*)startLabel+11836)
#define v10316	((void*)startLabel+11871)
#define v10317	((void*)startLabel+11908)
#define v10318	((void*)startLabel+11951)
#define CT_v10324	((void*)startLabel+12004)
#define F0_Data_46Sequence_46addDigits3	((void*)startLabel+12012)
#define FN_Data_46Sequence_46appendTree4	((void*)startLabel+12060)
#define v10349	((void*)startLabel+12072)
#define v10328	((void*)startLabel+12076)
#define v10325	((void*)startLabel+12102)
#define v10350	((void*)startLabel+12116)
#define v10332	((void*)startLabel+12120)
#define v10329	((void*)startLabel+12146)
#define v10351	((void*)startLabel+12156)
#define v10336	((void*)startLabel+12160)
#define v10333	((void*)startLabel+12192)
#define v10352	((void*)startLabel+12202)
#define v10340	((void*)startLabel+12206)
#define v10337	((void*)startLabel+12238)
#define v10353	((void*)startLabel+12248)
#define v10344	((void*)startLabel+12252)
#define v10354	((void*)startLabel+12264)
#define v10348	((void*)startLabel+12268)
#define v10345	((void*)startLabel+12342)
#define v10341	((void*)startLabel+12347)
#define CT_v10355	((void*)startLabel+12368)
#define F0_Data_46Sequence_46appendTree4	((void*)startLabel+12376)
#define FN_LAMBDA9609	((void*)startLabel+12420)
#define CT_v10357	((void*)startLabel+12440)
#define CF_LAMBDA9609	((void*)startLabel+12448)
#define FN_Data_46Sequence_46addDigits4	((void*)startLabel+12476)
#define v10359	((void*)startLabel+12490)
#define v10361	((void*)startLabel+12506)
#define v10362	((void*)startLabel+12532)
#define v10363	((void*)startLabel+12566)
#define v10364	((void*)startLabel+12601)
#define v10365	((void*)startLabel+12637)
#define v10367	((void*)startLabel+12654)
#define v10368	((void*)startLabel+12689)
#define v10369	((void*)startLabel+12725)
#define v10370	((void*)startLabel+12762)
#define v10371	((void*)startLabel+12807)
#define v10373	((void*)startLabel+12824)
#define v10374	((void*)startLabel+12860)
#define v10375	((void*)startLabel+12897)
#define v10376	((void*)startLabel+12942)
#define v10377	((void*)startLabel+12988)
#define v10379	((void*)startLabel+13004)
#define v10380	((void*)startLabel+13040)
#define v10381	((void*)startLabel+13084)
#define v10382	((void*)startLabel+13129)
#define CT_v10388	((void*)startLabel+13180)
#define F0_Data_46Sequence_46addDigits4	((void*)startLabel+13188)
#define FN_Data_46Sequence_46appendTree1	((void*)startLabel+13228)
#define v10413	((void*)startLabel+13240)
#define v10392	((void*)startLabel+13244)
#define v10389	((void*)startLabel+13251)
#define v10414	((void*)startLabel+13262)
#define v10396	((void*)startLabel+13266)
#define v10393	((void*)startLabel+13273)
#define v10415	((void*)startLabel+13282)
#define v10400	((void*)startLabel+13286)
#define v10397	((void*)startLabel+13300)
#define v10416	((void*)startLabel+13310)
#define v10404	((void*)startLabel+13314)
#define v10401	((void*)startLabel+13328)
#define v10417	((void*)startLabel+13338)
#define v10408	((void*)startLabel+13342)
#define v10418	((void*)startLabel+13354)
#define v10412	((void*)startLabel+13358)
#define v10409	((void*)startLabel+13398)
#define v10405	((void*)startLabel+13403)
#define CT_v10419	((void*)startLabel+13424)
#define F0_Data_46Sequence_46appendTree1	((void*)startLabel+13432)
#define FN_LAMBDA9610	((void*)startLabel+13476)
#define CT_v10421	((void*)startLabel+13496)
#define CF_LAMBDA9610	((void*)startLabel+13504)
#define FN_Data_46Sequence_46addDigits1	((void*)startLabel+13524)
#define v10423	((void*)startLabel+13538)
#define v10425	((void*)startLabel+13554)
#define v10426	((void*)startLabel+13572)
#define v10427	((void*)startLabel+13598)
#define v10428	((void*)startLabel+13625)
#define v10429	((void*)startLabel+13653)
#define v10431	((void*)startLabel+13670)
#define v10432	((void*)startLabel+13696)
#define v10433	((void*)startLabel+13723)
#define v10434	((void*)startLabel+13751)
#define v10435	((void*)startLabel+13787)
#define v10437	((void*)startLabel+13804)
#define v10438	((void*)startLabel+13831)
#define v10439	((void*)startLabel+13859)
#define v10440	((void*)startLabel+13895)
#define v10441	((void*)startLabel+13932)
#define v10443	((void*)startLabel+13948)
#define v10444	((void*)startLabel+13976)
#define v10445	((void*)startLabel+14012)
#define v10446	((void*)startLabel+14049)
#define CT_v10452	((void*)startLabel+14092)
#define F0_Data_46Sequence_46addDigits1	((void*)startLabel+14100)
#define FN_Data_46Sequence_46addDigits0	((void*)startLabel+14144)
#define v10454	((void*)startLabel+14158)
#define v10456	((void*)startLabel+14174)
#define v10457	((void*)startLabel+14190)
#define v10458	((void*)startLabel+14208)
#define v10459	((void*)startLabel+14232)
#define v10460	((void*)startLabel+14259)
#define v10462	((void*)startLabel+14274)
#define v10463	((void*)startLabel+14292)
#define v10464	((void*)startLabel+14316)
#define v10465	((void*)startLabel+14343)
#define v10466	((void*)startLabel+14373)
#define v10468	((void*)startLabel+14388)
#define v10469	((void*)startLabel+14412)
#define v10470	((void*)startLabel+14439)
#define v10471	((void*)startLabel+14469)
#define v10472	((void*)startLabel+14504)
#define v10474	((void*)startLabel+14520)
#define v10475	((void*)startLabel+14547)
#define v10476	((void*)startLabel+14577)
#define v10477	((void*)startLabel+14612)
#define CT_v10483	((void*)startLabel+14656)
#define F0_Data_46Sequence_46addDigits0	((void*)startLabel+14664)
#define FN_Data_46Sequence_46appendTree0	((void*)startLabel+14704)
#define v10508	((void*)startLabel+14716)
#define v10487	((void*)startLabel+14720)
#define v10484	((void*)startLabel+14723)
#define v10509	((void*)startLabel+14734)
#define v10491	((void*)startLabel+14738)
#define v10488	((void*)startLabel+14741)
#define v10510	((void*)startLabel+14750)
#define v10495	((void*)startLabel+14754)
#define v10492	((void*)startLabel+14763)
#define v10511	((void*)startLabel+14772)
#define v10499	((void*)startLabel+14776)
#define v10496	((void*)startLabel+14785)
#define v10512	((void*)startLabel+14794)
#define v10503	((void*)startLabel+14798)
#define v10513	((void*)startLabel+14810)
#define v10507	((void*)startLabel+14814)
#define v10504	((void*)startLabel+14842)
#define v10500	((void*)startLabel+14847)
#define CT_v10514	((void*)startLabel+14868)
#define F0_Data_46Sequence_46appendTree0	((void*)startLabel+14876)
#define FN_LAMBDA9611	((void*)startLabel+14916)
#define CT_v10516	((void*)startLabel+14936)
#define CF_LAMBDA9611	((void*)startLabel+14944)
#define CT_v10517	((void*)startLabel+14972)
#define CT_v10518	((void*)startLabel+15012)
#define CT_v10519	((void*)startLabel+15060)
#define CT_v10520	((void*)startLabel+15108)
#define CT_v10521	((void*)startLabel+15160)
#define CT_v10522	((void*)startLabel+15208)
#define CT_v10523	((void*)startLabel+15252)
#define CT_v10524	((void*)startLabel+15300)
#define CT_v10525	((void*)startLabel+15340)
#define CT_v10526	((void*)startLabel+15376)
#define CT_v10527	((void*)startLabel+15420)
#define CT_v10528	((void*)startLabel+15468)
#define CT_v10529	((void*)startLabel+15512)
#define CT_v10530	((void*)startLabel+15560)
#define CT_v10531	((void*)startLabel+15592)
#define FN_Data_46Sequence_46getElem	((void*)startLabel+15612)
#define CT_v10532	((void*)startLabel+15620)
#define F0_Data_46Sequence_46getElem	((void*)startLabel+15628)
#define v10534	((void*)startLabel+15650)
#define v10535	((void*)startLabel+15655)
#define CT_v10537	((void*)startLabel+15668)
#define v10539	((void*)startLabel+15702)
#define v10540	((void*)startLabel+15751)
#define CT_v10542	((void*)startLabel+15828)
#define FN_LAMBDA9613	((void*)startLabel+15884)
#define CT_v10543	((void*)startLabel+15908)
#define F0_LAMBDA9613	((void*)startLabel+15916)
#define FN_LAMBDA9612	((void*)startLabel+15932)
#define CT_v10544	((void*)startLabel+15956)
#define F0_LAMBDA9612	((void*)startLabel+15964)
#define CT_v10545	((void*)startLabel+15992)
#define CT_v10546	((void*)startLabel+16040)
#define CT_v10547	((void*)startLabel+16084)
#define CT_v10548	((void*)startLabel+16136)
#define v10550	((void*)startLabel+16178)
#define v10551	((void*)startLabel+16201)
#define CT_v10553	((void*)startLabel+16244)
#define v10555	((void*)startLabel+16282)
#define v10556	((void*)startLabel+16308)
#define CT_v10558	((void*)startLabel+16352)
#define CT_v10559	((void*)startLabel+16392)
#define CT_v10560	((void*)startLabel+16436)
#define CT_v10561	((void*)startLabel+16484)
#define CT_v10562	((void*)startLabel+16528)
#define CT_v10563	((void*)startLabel+16580)
#define FN_LAMBDA9614	((void*)startLabel+16612)
#define CT_v10564	((void*)startLabel+16636)
#define F0_LAMBDA9614	((void*)startLabel+16644)
#define v10566	((void*)startLabel+16684)
#define v10567	((void*)startLabel+16705)
#define v10568	((void*)startLabel+16752)
#define v10569	((void*)startLabel+16817)
#define CT_v10571	((void*)startLabel+16912)
#define FN_LAMBDA9618	((void*)startLabel+16976)
#define CT_v10572	((void*)startLabel+17000)
#define F0_LAMBDA9618	((void*)startLabel+17008)
#define FN_LAMBDA9617	((void*)startLabel+17024)
#define CT_v10573	((void*)startLabel+17048)
#define F0_LAMBDA9617	((void*)startLabel+17056)
#define FN_LAMBDA9616	((void*)startLabel+17072)
#define CT_v10574	((void*)startLabel+17096)
#define F0_LAMBDA9616	((void*)startLabel+17104)
#define FN_LAMBDA9615	((void*)startLabel+17116)
#define CT_v10575	((void*)startLabel+17136)
#define F0_LAMBDA9615	((void*)startLabel+17144)
#define CT_v10576	((void*)startLabel+17172)
#define CT_v10577	((void*)startLabel+17220)
#define CT_v10578	((void*)startLabel+17264)
#define CT_v10579	((void*)startLabel+17316)
#define v10581	((void*)startLabel+17362)
#define v10582	((void*)startLabel+17367)
#define v10583	((void*)startLabel+17379)
#define v10584	((void*)startLabel+17402)
#define CT_v10586	((void*)startLabel+17444)
#define v10588	((void*)startLabel+17486)
#define v10589	((void*)startLabel+17491)
#define v10590	((void*)startLabel+17503)
#define v10591	((void*)startLabel+17528)
#define CT_v10593	((void*)startLabel+17568)
#define v10595	((void*)startLabel+17610)
#define v10596	((void*)startLabel+17621)
#define v10597	((void*)startLabel+17642)
#define v10598	((void*)startLabel+17672)
#define CT_v10600	((void*)startLabel+17720)
#define v10602	((void*)startLabel+17762)
#define v10603	((void*)startLabel+17772)
#define v10604	((void*)startLabel+17795)
#define v10605	((void*)startLabel+17826)
#define CT_v10607	((void*)startLabel+17876)
#define CT_v10608	((void*)startLabel+17920)
#define CT_v10609	((void*)startLabel+17964)
#define v10611	((void*)startLabel+18008)
#define v10612	((void*)startLabel+18020)
#define v10613	((void*)startLabel+18043)
#define CT_v10615	((void*)startLabel+18132)
#define FN_LAMBDA9620	((void*)startLabel+18208)
#define CT_v10616	((void*)startLabel+18232)
#define F0_LAMBDA9620	((void*)startLabel+18240)
#define FN_LAMBDA9619	((void*)startLabel+18252)
#define CT_v10617	((void*)startLabel+18272)
#define F0_LAMBDA9619	((void*)startLabel+18280)
#define CT_v10618	((void*)startLabel+18308)
#define CT_v10619	((void*)startLabel+18356)
#define CT_v10620	((void*)startLabel+18400)
#define v10622	((void*)startLabel+18444)
#define v10623	((void*)startLabel+18449)
#define v10624	((void*)startLabel+18462)
#define CT_v10626	((void*)startLabel+18512)
#define v10628	((void*)startLabel+18564)
#define v10629	((void*)startLabel+18571)
#define v10630	((void*)startLabel+18576)
#define CT_v10632	((void*)startLabel+18608)
#define FN_LAMBDA9621	((void*)startLabel+18652)
#define CT_v10634	((void*)startLabel+18672)
#define CF_LAMBDA9621	((void*)startLabel+18680)
#define v10636	((void*)startLabel+18708)
#define v10637	((void*)startLabel+18715)
#define v10638	((void*)startLabel+18720)
#define CT_v10640	((void*)startLabel+18756)
#define FN_LAMBDA9622	((void*)startLabel+18804)
#define CT_v10642	((void*)startLabel+18824)
#define CF_LAMBDA9622	((void*)startLabel+18832)
#define v10644	((void*)startLabel+18860)
#define v10645	((void*)startLabel+18863)
#define v10646	((void*)startLabel+18874)
#define CT_v10648	((void*)startLabel+18904)
#define v10650	((void*)startLabel+18952)
#define v10651	((void*)startLabel+18955)
#define v10652	((void*)startLabel+18965)
#define CT_v10654	((void*)startLabel+19000)
#define CT_v10655	((void*)startLabel+19056)
#define CT_v10656	((void*)startLabel+19100)
#define v10658	((void*)startLabel+19144)
#define v10659	((void*)startLabel+19148)
#define v10660	((void*)startLabel+19162)
#define CT_v10662	((void*)startLabel+19172)
#define CT_v10663	((void*)startLabel+19212)
#define FN_Data_46Sequence_46seqTc	((void*)startLabel+19240)
#define CT_v10664	((void*)startLabel+19252)
#define CF_Data_46Sequence_46seqTc	((void*)startLabel+19260)
#define FN_LAMBDA9623	((void*)startLabel+19280)
#define CT_v10666	((void*)startLabel+19300)
#define CF_LAMBDA9623	((void*)startLabel+19308)
#define CT_v10667	((void*)startLabel+19344)
#define CT_v10668	((void*)startLabel+19388)
#define CT_v10669	((void*)startLabel+19424)
#define CT_v10670	((void*)startLabel+19460)
#define CT_v10671	((void*)startLabel+19520)
#define FN_LAMBDA9627	((void*)startLabel+19560)
#define CT_v10672	((void*)startLabel+19580)
#define F0_LAMBDA9627	((void*)startLabel+19588)
#define FN_LAMBDA9626	((void*)startLabel+19616)
#define v10746	((void*)startLabel+19632)
#define v10680	((void*)startLabel+19636)
#define v10747	((void*)startLabel+19650)
#define v10684	((void*)startLabel+19654)
#define v10748	((void*)startLabel+19664)
#define v10688	((void*)startLabel+19668)
#define v10749	((void*)startLabel+19682)
#define v10692	((void*)startLabel+19686)
#define v10750	((void*)startLabel+19696)
#define v10696	((void*)startLabel+19700)
#define v10751	((void*)startLabel+19714)
#define v10700	((void*)startLabel+19718)
#define v10752	((void*)startLabel+19728)
#define v10704	((void*)startLabel+19732)
#define v10753	((void*)startLabel+19746)
#define v10708	((void*)startLabel+19750)
#define v10754	((void*)startLabel+19760)
#define v10712	((void*)startLabel+19764)
#define v10755	((void*)startLabel+19778)
#define v10716	((void*)startLabel+19782)
#define v10756	((void*)startLabel+19792)
#define v10720	((void*)startLabel+19796)
#define v10757	((void*)startLabel+19810)
#define v10724	((void*)startLabel+19814)
#define v10758	((void*)startLabel+19824)
#define v10728	((void*)startLabel+19828)
#define v10759	((void*)startLabel+19842)
#define v10732	((void*)startLabel+19846)
#define v10760	((void*)startLabel+19856)
#define v10736	((void*)startLabel+19860)
#define v10761	((void*)startLabel+19874)
#define v10740	((void*)startLabel+19878)
#define v10762	((void*)startLabel+19888)
#define v10744	((void*)startLabel+19892)
#define v10737	((void*)startLabel+19914)
#define v10729	((void*)startLabel+19919)
#define v10721	((void*)startLabel+19924)
#define v10713	((void*)startLabel+19929)
#define v10705	((void*)startLabel+19934)
#define v10697	((void*)startLabel+19939)
#define v10689	((void*)startLabel+19944)
#define v10681	((void*)startLabel+19949)
#define v10677	((void*)startLabel+19954)
#define v10673	((void*)startLabel+19959)
#define CT_v10763	((void*)startLabel+19972)
#define F0_LAMBDA9626	((void*)startLabel+19980)
#define FN_LAMBDA9625	((void*)startLabel+20020)
#define CT_v10765	((void*)startLabel+20040)
#define CF_LAMBDA9625	((void*)startLabel+20048)
#define FN_LAMBDA9624	((void*)startLabel+20060)
#define CT_v10769	((void*)startLabel+20096)
#define F0_LAMBDA9624	((void*)startLabel+20104)
#define CT_v10770	((void*)startLabel+20144)
#define CT_v10771	((void*)startLabel+20240)
#define FN_LAMBDA9628	((void*)startLabel+20304)
#define CT_v10773	((void*)startLabel+20324)
#define CF_LAMBDA9628	((void*)startLabel+20332)
#define CT_v10774	((void*)startLabel+20364)
#define CT_v10775	((void*)startLabel+20412)
#define CT_v10776	((void*)startLabel+20460)
#define CT_v10777	((void*)startLabel+20524)
#define CT_v10778	((void*)startLabel+20580)
#define CT_v10779	((void*)startLabel+20628)
#define CT_v10780	((void*)startLabel+20676)
#define CT_v10781	((void*)startLabel+20724)
#define CT_v10782	((void*)startLabel+20772)
#define CT_v10783	((void*)startLabel+20820)
#define CT_v10784	((void*)startLabel+20904)
#define CT_v10785	((void*)startLabel+20972)
#define CT_v10786	((void*)startLabel+21016)
#define CT_v10787	((void*)startLabel+21052)
#define CT_v10788	((void*)startLabel+21100)
#define FN_Data_46Sequence_46Prelude_46407_46add	((void*)startLabel+21140)
#define CT_v10789	((void*)startLabel+21160)
#define F0_Data_46Sequence_46Prelude_46407_46add	((void*)startLabel+21168)
#define CT_v10790	((void*)startLabel+21200)
#define CT_v10791	((void*)startLabel+21236)
#define CT_v10792	((void*)startLabel+21280)
#define CT_v10793	((void*)startLabel+21344)
#define CT_v10794	((void*)startLabel+21400)
#define CT_v10795	((void*)startLabel+21448)
#define CT_v10796	((void*)startLabel+21492)
#define CT_v10797	((void*)startLabel+21544)
#define FN_Data_46Sequence_46Prelude_46397_46f_39	((void*)startLabel+21580)
#define CT_v10798	((void*)startLabel+21596)
#define F0_Data_46Sequence_46Prelude_46397_46f_39	((void*)startLabel+21604)
#define CT_v10799	((void*)startLabel+21640)
#define FN_Data_46Sequence_46Prelude_46391_46f_39	((void*)startLabel+21676)
#define CT_v10800	((void*)startLabel+21692)
#define F0_Data_46Sequence_46Prelude_46391_46f_39	((void*)startLabel+21700)
#define CT_v10801	((void*)startLabel+21732)
#define CT_v10802	((void*)startLabel+21784)
#define CT_v10803	((void*)startLabel+21836)
#define CT_v10804	((void*)startLabel+21880)
#define CT_v10805	((void*)startLabel+21928)
#define CT_v10806	((void*)startLabel+21980)
#define FN_LAMBDA9629	((void*)startLabel+22008)
#define CT_v10808	((void*)startLabel+22028)
#define CF_LAMBDA9629	((void*)startLabel+22036)
#define CT_v10809	((void*)startLabel+22064)
#define FN_LAMBDA9633	((void*)startLabel+22092)
#define CT_v10810	((void*)startLabel+22108)
#define F0_LAMBDA9633	((void*)startLabel+22116)
#define FN_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec_392069	((void*)startLabel+22136)
#define CT_v10811	((void*)startLabel+22208)
#define F0_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec_392069	((void*)startLabel+22216)
#define FN_LAMBDA9632	((void*)startLabel+22260)
#define CT_v10813	((void*)startLabel+22280)
#define CF_LAMBDA9632	((void*)startLabel+22288)
#define FN_LAMBDA9631	((void*)startLabel+22300)
#define CT_v10815	((void*)startLabel+22320)
#define CF_LAMBDA9631	((void*)startLabel+22328)
#define FN_LAMBDA9630	((void*)startLabel+22344)
#define CT_v10816	((void*)startLabel+22368)
#define F0_LAMBDA9630	((void*)startLabel+22376)
#define CT_v10817	((void*)startLabel+22404)
#define CT_v10818	((void*)startLabel+22508)
#define FN_LAMBDA9637	((void*)startLabel+22564)
#define CT_v10819	((void*)startLabel+22584)
#define CF_LAMBDA9637	((void*)startLabel+22592)
#define FN_LAMBDA9636	((void*)startLabel+22604)
#define CT_v10820	((void*)startLabel+22616)
#define F0_LAMBDA9636	((void*)startLabel+22624)
#define FN_LAMBDA9635	((void*)startLabel+22636)
#define v10825	((void*)startLabel+22646)
#define v10824	((void*)startLabel+22650)
#define v10821	((void*)startLabel+22657)
#define CT_v10826	((void*)startLabel+22676)
#define F0_LAMBDA9635	((void*)startLabel+22684)
#define FN_LAMBDA9634	((void*)startLabel+22704)
#define CT_v10828	((void*)startLabel+22724)
#define CF_LAMBDA9634	((void*)startLabel+22732)
#define v10830	((void*)startLabel+22760)
#define v10831	((void*)startLabel+22770)
#define CT_v10833	((void*)startLabel+22860)
#define FN_LAMBDA9639	((void*)startLabel+22924)
#define CT_v10834	((void*)startLabel+22944)
#define CF_LAMBDA9639	((void*)startLabel+22952)
#define FN_LAMBDA9638	((void*)startLabel+22964)
#define CT_v10835	((void*)startLabel+22984)
#define CF_LAMBDA9638	((void*)startLabel+22992)
#define CT_v10836	((void*)startLabel+23024)
#define CT_v10837	((void*)startLabel+23072)
#define v10841	((void*)startLabel+23114)
#define v10856	((void*)startLabel+23124)
#define v10845	((void*)startLabel+23128)
#define v10846	((void*)startLabel+23133)
#define v10857	((void*)startLabel+23144)
#define v10850	((void*)startLabel+23148)
#define v10852	((void*)startLabel+23172)
#define v10853	((void*)startLabel+23177)
#define v10854	((void*)startLabel+23186)
#define v10847	((void*)startLabel+23190)
#define v10838	((void*)startLabel+23195)
#define CT_v10859	((void*)startLabel+23232)
#define v10863	((void*)startLabel+23282)
#define v10874	((void*)startLabel+23292)
#define v10867	((void*)startLabel+23296)
#define v10868	((void*)startLabel+23301)
#define v10875	((void*)startLabel+23312)
#define v10872	((void*)startLabel+23316)
#define v10869	((void*)startLabel+23361)
#define v10860	((void*)startLabel+23366)
#define CT_v10876	((void*)startLabel+23388)
#define CT_v10877	((void*)startLabel+23456)
#define CT_v10878	((void*)startLabel+23504)
#define CT_v10879	((void*)startLabel+23552)
#define CT_v10880	((void*)startLabel+23600)
#define CT_v10881	((void*)startLabel+23648)
#define v10885	((void*)startLabel+23690)
#define v10896	((void*)startLabel+23700)
#define v10889	((void*)startLabel+23704)
#define v10890	((void*)startLabel+23709)
#define v10897	((void*)startLabel+23720)
#define v10894	((void*)startLabel+23724)
#define v10891	((void*)startLabel+23749)
#define v10882	((void*)startLabel+23754)
#define CT_v10898	((void*)startLabel+23772)
#define CT_v10899	((void*)startLabel+23828)
#define CT_v10900	((void*)startLabel+23872)
#define FN_LAMBDA9643	((void*)startLabel+23900)
#define CT_v10901	((void*)startLabel+23916)
#define F0_LAMBDA9643	((void*)startLabel+23924)
#define FN_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec_392052	((void*)startLabel+23944)
#define CT_v10902	((void*)startLabel+24016)
#define F0_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec_392052	((void*)startLabel+24024)
#define FN_LAMBDA9642	((void*)startLabel+24068)
#define CT_v10904	((void*)startLabel+24088)
#define CF_LAMBDA9642	((void*)startLabel+24096)
#define FN_LAMBDA9641	((void*)startLabel+24108)
#define CT_v10906	((void*)startLabel+24128)
#define CF_LAMBDA9641	((void*)startLabel+24136)
#define FN_LAMBDA9640	((void*)startLabel+24152)
#define CT_v10907	((void*)startLabel+24176)
#define F0_LAMBDA9640	((void*)startLabel+24184)
#define CT_v10908	((void*)startLabel+24212)
#define CT_v10909	((void*)startLabel+24316)
#define FN_LAMBDA9647	((void*)startLabel+24372)
#define CT_v10910	((void*)startLabel+24392)
#define CF_LAMBDA9647	((void*)startLabel+24400)
#define FN_LAMBDA9646	((void*)startLabel+24412)
#define CT_v10911	((void*)startLabel+24424)
#define F0_LAMBDA9646	((void*)startLabel+24432)
#define FN_LAMBDA9645	((void*)startLabel+24444)
#define v10916	((void*)startLabel+24454)
#define v10915	((void*)startLabel+24458)
#define v10912	((void*)startLabel+24465)
#define CT_v10917	((void*)startLabel+24484)
#define F0_LAMBDA9645	((void*)startLabel+24492)
#define FN_LAMBDA9644	((void*)startLabel+24512)
#define CT_v10919	((void*)startLabel+24532)
#define CF_LAMBDA9644	((void*)startLabel+24540)
#define v10921	((void*)startLabel+24568)
#define v10922	((void*)startLabel+24578)
#define CT_v10924	((void*)startLabel+24668)
#define FN_LAMBDA9649	((void*)startLabel+24732)
#define CT_v10925	((void*)startLabel+24752)
#define CF_LAMBDA9649	((void*)startLabel+24760)
#define FN_LAMBDA9648	((void*)startLabel+24772)
#define CT_v10926	((void*)startLabel+24792)
#define CF_LAMBDA9648	((void*)startLabel+24800)
#define CT_v10927	((void*)startLabel+24832)
#define CT_v10928	((void*)startLabel+24880)
#define v10932	((void*)startLabel+24922)
#define v10947	((void*)startLabel+24932)
#define v10936	((void*)startLabel+24936)
#define v10937	((void*)startLabel+24941)
#define v10948	((void*)startLabel+24952)
#define v10941	((void*)startLabel+24956)
#define v10943	((void*)startLabel+24976)
#define v10944	((void*)startLabel+24981)
#define v10945	((void*)startLabel+24997)
#define v10938	((void*)startLabel+25001)
#define v10929	((void*)startLabel+25006)
#define CT_v10950	((void*)startLabel+25044)
#define v10954	((void*)startLabel+25094)
#define v10965	((void*)startLabel+25104)
#define v10958	((void*)startLabel+25108)
#define v10959	((void*)startLabel+25113)
#define v10966	((void*)startLabel+25124)
#define v10963	((void*)startLabel+25128)
#define v10960	((void*)startLabel+25170)
#define v10951	((void*)startLabel+25175)
#define CT_v10967	((void*)startLabel+25196)
#define CT_v10968	((void*)startLabel+25264)
#define CT_v10969	((void*)startLabel+25312)
#define CT_v10970	((void*)startLabel+25360)
#define CT_v10971	((void*)startLabel+25408)
#define CT_v10972	((void*)startLabel+25456)
#define v10976	((void*)startLabel+25498)
#define v10987	((void*)startLabel+25508)
#define v10980	((void*)startLabel+25512)
#define v10981	((void*)startLabel+25517)
#define v10988	((void*)startLabel+25528)
#define v10985	((void*)startLabel+25532)
#define v10982	((void*)startLabel+25557)
#define v10973	((void*)startLabel+25562)
#define CT_v10989	((void*)startLabel+25580)
#define CT_v10990	((void*)startLabel+25636)
#define CT_v10991	((void*)startLabel+25692)
#define CT_v10992	((void*)startLabel+25796)
#define CT_v10993	((void*)startLabel+25896)
#define CT_v10994	((void*)startLabel+25960)
#define CT_v10995	((void*)startLabel+26016)
#define CT_v10996	((void*)startLabel+26120)
#define CT_v10997	((void*)startLabel+26220)
#define CT_v10998	((void*)startLabel+26284)
#define CT_v10999	((void*)startLabel+26324)
#define CT_v11000	((void*)startLabel+26364)
#define CT_v11001	((void*)startLabel+26416)
#define CT_v11002	((void*)startLabel+26488)
#define CT_v11003	((void*)startLabel+26556)
#define CT_v11004	((void*)startLabel+26616)
#define CT_v11005	((void*)startLabel+26676)
#define CT_v11006	((void*)startLabel+26780)
#define CT_v11007	((void*)startLabel+26880)
#define CT_v11008	((void*)startLabel+26944)
#define CT_v11009	((void*)startLabel+26996)
#define CT_v11010	((void*)startLabel+27048)
#define CT_v11011	((void*)startLabel+27096)
#define CT_v11012	((void*)startLabel+27144)
#define CT_v11013	((void*)startLabel+27196)
#define CT_v11014	((void*)startLabel+27260)
#define CT_v11015	((void*)startLabel+27312)
#define CT_v11016	((void*)startLabel+27384)
#define CT_v11017	((void*)startLabel+27448)
#define CT_v11018	((void*)startLabel+27500)
#define CT_v11019	((void*)startLabel+27568)
#define CT_v11020	((void*)startLabel+27620)
#define CT_v11021	((void*)startLabel+27684)
#define CT_v11022	((void*)startLabel+27736)
#define CT_v11023	((void*)startLabel+27800)
#define CT_v11024	((void*)startLabel+27844)
#define CT_v11025	((void*)startLabel+27888)
#define CT_v11026	((void*)startLabel+27940)
#define CT_v11027	((void*)startLabel+28012)
#define CT_v11028	((void*)startLabel+28076)
#define CT_v11029	((void*)startLabel+28124)
#define CT_v11030	((void*)startLabel+28168)
#define CT_v11031	((void*)startLabel+28220)
#define CT_v11032	((void*)startLabel+28292)
#define CT_v11033	((void*)startLabel+28356)
#define CT_v11034	((void*)startLabel+28404)
#define CT_v11035	((void*)startLabel+28448)
#define CT_v11036	((void*)startLabel+28500)
#define CT_v11037	((void*)startLabel+28572)
#define ST_v10814	((void*)startLabel+28608)
#define ST_v10905	((void*)startLabel+28611)
#define ST_v10827	((void*)startLabel+28614)
#define ST_v10918	((void*)startLabel+28678)
#define ST_v10515	((void*)startLabel+28742)
#define ST_v10420	((void*)startLabel+28808)
#define ST_v10228	((void*)startLabel+28874)
#define ST_v10292	((void*)startLabel+28940)
#define ST_v10356	((void*)startLabel+29006)
#define ST_v10105	((void*)startLabel+29073)
#define ST_v10093	((void*)startLabel+29139)
#define ST_v10074	((void*)startLabel+29205)
#define ST_v10055	((void*)startLabel+29271)
#define ST_v10025	((void*)startLabel+29337)
#define ST_v10016	((void*)startLabel+29403)
#define ST_v10000	((void*)startLabel+29469)
#define ST_v9981	((void*)startLabel+29535)
#define ST_v9944	((void*)startLabel+29601)
#define ST_v9917	((void*)startLabel+29667)
#define ST_v9819	((void*)startLabel+29733)
#define ST_v9800	((void*)startLabel+29799)
#define ST_v10812	((void*)startLabel+29866)
#define ST_v10903	((void*)startLabel+29873)
#define ST_v10807	((void*)startLabel+29880)
#define ST_v10665	((void*)startLabel+29924)
#define ST_v10186	((void*)startLabel+29928)
#define ST_v10146	((void*)startLabel+29934)
#define ST_v10018	((void*)startLabel+29940)
#define ST_v10633	((void*)startLabel+29965)
#define ST_v10168	((void*)startLabel+29988)
#define ST_v10641	((void*)startLabel+30007)
#define ST_v10128	((void*)startLabel+30030)
#define ST_v10772	((void*)startLabel+30049)
#define ST_v10107	((void*)startLabel+30059)
#define ST_v10095	((void*)startLabel+30079)
#define ST_v10764	((void*)startLabel+30104)
#define ST_v9919	((void*)startLabel+30143)
extern Node FN_NHC_46Internal_46_95apply1[];
extern Node F0_Prelude_46id[];
extern Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit_46size[];
extern Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size[];
extern Node CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node[];
extern Node FN_Prelude_46Num_46Prelude_46Int_46_43[];
extern Node FN_Data_46Sequence_46size[];
extern Node FN_Prelude_46seq[];
extern Node CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem[];
extern Node FN_Data_46List_46foldl_39[];
extern Node CF_Prelude_46otherwise[];
extern Node FN_NHC_46Internal_46_95patternMatchFail[];
extern Node FN_Prelude_46Num_46Prelude_46Int_46_45[];
extern Node FN_Prelude_46error[];
extern Node FN_Prelude_46maybe[];
extern Node FN_Prelude_46_46[];
extern Node F0_Prelude_46snd[];
extern Node F0_Prelude_46fst[];
extern Node FN_NHC_46Internal_46_95apply2[];
extern Node FN_Prelude_46Ord_46Prelude_46Int_46_60_61[];
extern Node FN_Prelude_46Ord_46Prelude_46Int_46_60[];
extern Node FN_Prelude_46_38_38[];
extern Node FN_Prelude_46Functor_46Data_46Sequence_46Elem_46fmap[];
extern Node FN_Prelude_46const[];
extern Node FN_Control_46Applicative_46pure[];
extern Node FN_Control_46Applicative_46Applicative_46Prelude_46Functor[];
extern Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46traverse[];
extern Node FN_Control_46Applicative_46_60_36_62[];
extern Node FN_Control_46Applicative_46_60_42_62[];
extern Node FN_Data_46Traversable_46_95_46sequence[];
extern Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR[];
extern Node FN_Data_46Traversable_46_95_46mapM[];
extern Node FN_Data_46Traversable_46_95_46sequenceA[];
extern Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr[];
extern Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl[];
extern Node FN_Data_46Foldable_46_95_46foldl1[];
extern Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR[];
extern Node FN_Data_46Foldable_46_95_46foldMap[];
extern Node FN_Data_46Foldable_46_95_46fold[];
extern Node FN_Data_46Traversable_46fmapDefault[];
extern Node FN_Data_46Typeable_46typeOfDefault[];
extern Node CF_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewR[];
extern Node FN_Data_46Typeable_46mkTyCon[];
extern Node FN_Data_46Typeable_46mkTyConApp[];
extern Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL[];
extern Node FN_Data_46Foldable_46_95_46foldr1[];
extern Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL[];
extern Node CF_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewL[];
extern Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46Node_46size[];
extern Node F0_NHC_46Internal_46_95id[];
extern Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem[];
extern Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem[];
extern Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Node[];
extern Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Node[];
extern Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl[];
extern Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit[];
extern Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit[];
extern Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree[];
extern Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl[];
extern Node FN_Prelude_46flip[];
extern Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr[];
extern Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree[];
extern Node CF_Data_46Typeable_46Typeable1_46Data_46Sequence_46Seq[];
extern Node FN_Data_46Monoid_46_95_46mconcat[];
extern Node CF_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq[];
extern Node FN_Prelude_46Ord_46Prelude_46Int_46_62[];
extern Node FN_Prelude_46readParen[];
extern Node FN_Prelude_46_36[];
extern Node FN_Prelude_46lex[];
extern Node FN_Prelude_46Monad_46Prelude_46_91_93_46_62_62_61[];
extern Node FN_Prelude_46Read_46Prelude_46_91_93[];
extern Node FN_Prelude_46reads[];
extern Node FN_Prelude_46Monad_46Prelude_46_91_93_46fail[];
extern Node FN_Prelude_46Monad_46Prelude_46_91_93_46return[];
extern Node FN_Prelude_46Read_46Data_46Sequence_46Seq[];
extern Node FN_Prelude_46_95_46readList[];
extern Node FN_Prelude_46showParen[];
extern Node FN_Prelude_46showString[];
extern Node FN_Prelude_46Show_46Prelude_46_91_93[];
extern Node FN_Prelude_46shows[];
extern Node FN_Data_46Foldable_46toList[];
extern Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq[];
extern Node FN_Prelude_46Show_46Data_46Sequence_46Seq[];
extern Node FN_Prelude_46_95_46show[];
extern Node FN_Prelude_46_95_46showsType[];
extern Node FN_Prelude_46_95_46showList[];
extern Node FN_Prelude_46Ord_46Prelude_46_91_93_46compare[];
extern Node FN_Prelude_46Ord_46Data_46Sequence_46Seq[];
extern Node FN_Prelude_46_95_46min[];
extern Node FN_Prelude_46_95_46max[];
extern Node FN_Prelude_46_95_46_62[];
extern Node FN_Prelude_46_95_46_62_61[];
extern Node FN_Prelude_46_95_46_60[];
extern Node FN_Prelude_46_95_46_60_61[];
extern Node FN_Prelude_46Eq_46Prelude_46Int_46_61_61[];
extern Node FN_Prelude_46Eq_46Prelude_46_91_93_46_61_61[];
extern Node FN_Prelude_46Eq_46Data_46Sequence_46Seq[];
extern Node FN_Prelude_46_95_46_47_61[];
extern Node FN_Data_46Foldable_46foldl_39[];
extern Node FN_Prelude_46_95_46fail[];
extern Node CF_Prelude_46Monad_46Data_46Sequence_46Seq[];
extern Node FN_Prelude_46_95_46_62_62[];
extern Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq[];
extern Node FN_NHC_46Internal_46_95noMethodError[];
extern Node FN_Prelude_46_95readConInfix[];
extern Node FN_Prelude_46_95readCon0[];
extern Node FN_Prelude_46_43_43[];
extern Node FN_Prelude_46Read_46Data_46Sequence_46ViewL[];
extern Node FN_Prelude_46showChar[];
extern Node FN_Prelude_46showsType[];
extern Node FN_Prelude_46showsPrec[];
extern Node FN_Prelude_46Show_46Data_46Sequence_46ViewL[];
extern Node FN_Prelude_46compare[];
extern Node FN_Prelude_46_95fromEnum[];
extern Node FN_Prelude_46Ord_46Prelude_46Int_46compare[];
extern Node FN_Prelude_46_60[];
extern Node FN_Prelude_46Ord_46Prelude_46Eq[];
extern Node FN_Prelude_46_61_61[];
extern Node FN_Prelude_46_124_124[];
extern Node FN_Prelude_46Ord_46Data_46Sequence_46ViewL[];
extern Node FN_Prelude_46Eq_46Data_46Sequence_46ViewL[];
extern Node FN_Prelude_46Read_46Data_46Sequence_46ViewR[];
extern Node FN_Prelude_46Show_46Data_46Sequence_46ViewR[];
extern Node FN_Prelude_46_60_61[];
extern Node FN_Prelude_46Ord_46Data_46Sequence_46ViewR[];
extern Node FN_Prelude_46Eq_46Data_46Sequence_46ViewR[];

static Node startLabel[] = {
  42
,	/* C0_Data_46Sequence_46Empty: (byte 0) */
  CONSTR(0,0,0)
,	/* C0_Data_46Sequence_46Nothing2: (byte 0) */
  CONSTR(0,0,0)
,};
Node C0_Data_46Sequence_46EmptyL[] = {
  CONSTR(0,0,0)
,};
Node C0_Data_46Sequence_46EmptyR[] = {
  CONSTR(0,0,0)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v9740)
,	/* FN_Data_46Sequence_46reverseNode: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v9737: (byte 2) */
  bytes2word(TOP(23),BOT(23),UNPACK,3)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_I2)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_I1)
, bytes2word(HEAP_OFF_N1,8,HEAP_OFF_N1,6)
,	/* v9738: (byte 1) */
  bytes2word(RETURN,UNPACK,4,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_P1,3)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_I2)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_I1)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,9)
, bytes2word(HEAP_OFF_N1,7,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(1,4,0)
, CONSTR(0,3,0)
,	/* CT_v9740: (byte 0) */
  HW(1,2)
, 0
,	/* F0_Data_46Sequence_46reverseNode: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46reverseNode),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v9747)
,	/* FN_Data_46Sequence_46reverseDigit: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(21),BOT(21),TOP(40),BOT(40))
,	/* v9742: (byte 2) */
  bytes2word(TOP(64),BOT(64),UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v9743: (byte 3) */
  bytes2word(HEAP_OFF_N1,4,RETURN,UNPACK)
, bytes2word(2,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_I1,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,HEAP_OFF_N1,7,HEAP_OFF_N1)
,	/* v9744: (byte 2) */
  bytes2word(5,RETURN,UNPACK,3)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_I2)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_I1)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_IN3,HEAP_OFF_N1)
, bytes2word(10,HEAP_OFF_N1,8,HEAP_OFF_N1)
,	/* v9745: (byte 2) */
  bytes2word(6,RETURN,UNPACK,4)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_P1)
, bytes2word(3,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_I2,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_I1,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(4,HEAP_OFF_N1,13,HEAP_OFF_N1)
, bytes2word(11,HEAP_OFF_N1,9,HEAP_OFF_N1)
, bytes2word(7,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(3,4,0)
, CONSTR(2,3,0)
, CONSTR(1,2,0)
, CONSTR(0,1,0)
,	/* CT_v9747: (byte 0) */
  HW(1,2)
, 0
,	/* F0_Data_46Sequence_46reverseDigit: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46reverseDigit),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v9753)
,	/* FN_Data_46Sequence_46reverseTree: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v9749: (byte 4) */
  bytes2word(TOP(11),BOT(11),TOP(24),BOT(24))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v9750: (byte 1) */
  bytes2word(RETURN,UNPACK,1,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_OFF_N1)
,	/* v9751: (byte 2) */
  bytes2word(4,RETURN,UNPACK,4)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,HEAP_P1)
, bytes2word(3,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_P1,6,HEAP_OFF_N1,3)
, bytes2word(HEAP_I2,HEAP_CVAL_I4,HEAP_ARG,1)
, bytes2word(HEAP_I1,PUSH_HEAP,HEAP_CVAL_IN3,HEAP_I1)
, bytes2word(HEAP_OFF_N1,13,HEAP_OFF_N1,9)
, bytes2word(HEAP_OFF_N1,7,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
, CONSTR(1,1,0)
, CONSTR(0,0,0)
,	/* CT_v9753: (byte 0) */
  HW(4,2)
, 0
,	/* F0_Data_46Sequence_46reverseTree: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46reverseTree),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Data_46Sequence_46reverseDigit))
, CAPTAG(useLabel(FN_Data_46Sequence_46reverseNode),1)
, VAPTAG(useLabel(FN_Data_46Sequence_46reverseTree))
, bytes2word(1,0,0,1)
, useLabel(CT_v9754)
,};
Node FN_Data_46Sequence_46reverse[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v9754: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Data_46Sequence_46reverse[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46reverse),1)
, VAPTAG(useLabel(FN_Data_46Sequence_46reverseTree))
, useLabel(F0_Prelude_46id)
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v9755)
,	/* FN_Data_46Sequence_46deep: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_P1,6,HEAP_OFF_N1)
, bytes2word(7,HEAP_OFF_N1,5,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG_ARG,1,4,HEAP_CVAL_P1)
, bytes2word(6,HEAP_OFF_N1,7,HEAP_OFF_N1)
, bytes2word(5,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_OFF_N1,4,HEAP_ARG_ARG,2)
, bytes2word(3,HEAP_ARG,4,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
,	/* CT_v9755: (byte 0) */
  HW(4,4)
, 0
,	/* F0_Data_46Sequence_46deep: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46deep),4)
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit_46size))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v9756)
,	/* FN_Data_46Sequence_46node3: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I5,HEAP_OFF_N1,9)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,4,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(9,HEAP_OFF_N1,5,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_OFF_N1,4)
, bytes2word(HEAP_ARG_ARG,2,3,HEAP_ARG)
, bytes2word(4,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,4,0)
,	/* CT_v9756: (byte 0) */
  HW(3,4)
, 0
,	/* F0_Data_46Sequence_46node3: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46node3),4)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v9768)
,	/* FN_Data_46Sequence_46snocTree: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v9758: (byte 4) */
  bytes2word(TOP(13),BOT(13),TOP(35),BOT(35))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v9759: (byte 3) */
  bytes2word(HEAP_ARG,3,RETURN,UNPACK)
, bytes2word(1,HEAP_CVAL_N1,2,HEAP_P1)
, bytes2word(0,HEAP_CVAL_IN3,HEAP_CVAL_N1,2)
, bytes2word(HEAP_ARG,3,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,7)
, bytes2word(HEAP_OFF_N1,6,HEAP_OFF_N1,6)
,	/* v9760: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,PUSH_P1)
, bytes2word(3,ZAP_STACK_P1,4,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,4,NOP)
, bytes2word(TOP(8),BOT(8),TOP(41),BOT(41))
,	/* v9762: (byte 4) */
  bytes2word(TOP(75),BOT(75),TOP(111),BOT(111))
, bytes2word(UNPACK,1,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I5,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,6)
, bytes2word(HEAP_I1,HEAP_OFF_N1,5,HEAP_CVAL_N1)
, bytes2word(4,HEAP_P1,0,HEAP_ARG)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_N1,5)
, bytes2word(HEAP_OFF_N1,7,HEAP_P1,3)
, bytes2word(HEAP_P1,4,HEAP_OFF_N1,7)
,	/* v9763: (byte 1) */
  bytes2word(RETURN,UNPACK,2,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(3,HEAP_ARG,3,HEAP_CVAL_P1)
, bytes2word(6,HEAP_I2,HEAP_OFF_N1,5)
, bytes2word(HEAP_CVAL_N1,6,HEAP_P1,0)
, bytes2word(HEAP_I1,HEAP_ARG,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,5,HEAP_OFF_N1,8)
, bytes2word(HEAP_P1,4,HEAP_P1,5)
,	/* v9764: (byte 3) */
  bytes2word(HEAP_OFF_N1,8,RETURN,UNPACK)
, bytes2word(3,HEAP_CVAL_I4,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I5,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_P1,6,HEAP_P1)
, bytes2word(3,HEAP_OFF_N1,5,HEAP_CVAL_N1)
, bytes2word(7,HEAP_P1,0,HEAP_I1)
, bytes2word(HEAP_I2,HEAP_ARG,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,5,HEAP_OFF_N1,9)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
,	/* v9765: (byte 3) */
  bytes2word(HEAP_OFF_N1,9,RETURN,UNPACK)
, bytes2word(4,HEAP_CVAL_P1,7,HEAP_P1)
, bytes2word(4,HEAP_P1,5,HEAP_P1)
, bytes2word(6,HEAP_ARG,1,HEAP_P1)
, bytes2word(0,HEAP_I1,HEAP_I2,HEAP_P1)
, bytes2word(3,HEAP_ARG,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_P1,7)
, bytes2word(HEAP_OFF_N1,12,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(3,4,0)
, CONSTR(2,3,0)
, CONSTR(2,4,0)
, CONSTR(1,2,0)
, CONSTR(0,0,0)
, CONSTR(0,1,0)
, CONSTR(1,1,0)
,	/* CT_v9768: (byte 0) */
  HW(6,3)
, 0
,	/* F0_Data_46Sequence_46snocTree: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46snocTree),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46deep))
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_LAMBDA9570))
, VAPTAG(useLabel(FN_Prelude_46seq))
, bytes2word(9,0,8,1)
, bytes2word(7,2,6,3)
, bytes2word(5,4,4,5)
, bytes2word(3,6,2,7)
, bytes2word(1,8,0,9)
, useLabel(CT_v9769)
,	/* FN_LAMBDA9570: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,4)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(9,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG_ARG,4,5,HEAP_ARG_ARG)
, bytes2word(6,7,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,3)
, bytes2word(HEAP_OFF_N1,8,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,8,9,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,16)
, bytes2word(HEAP_ARG,2,HEAP_OFF_N1,10)
, bytes2word(HEAP_OFF_N1,7,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(2,4,0)
, CONSTR(1,2,0)
,	/* CT_v9769: (byte 0) */
  HW(6,9)
, 0
,	/* F0_LAMBDA9570: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9570),9)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46node3))
, VAPTAG(useLabel(FN_Data_46Sequence_46snocTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v9770)
,};
Node FN_Data_46Sequence_46_124_62[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v9770: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Sequence_46_124_62[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46_124_62),2)
, VAPTAG(useLabel(FN_Data_46Sequence_46snocTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, bytes2word(0,0,0,0)
, useLabel(CT_v9771)
,};
Node FN_Data_46Sequence_46empty[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,0,0)
,	/* CT_v9771: (byte 0) */
  HW(0,0)
, 0
,};
Node CF_Data_46Sequence_46empty[] = {
  VAPTAG(useLabel(FN_Data_46Sequence_46empty))
, bytes2word(0,0,0,0)
, useLabel(CT_v9772)
,};
Node FN_Data_46Sequence_46fromList[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_CVAL_I5,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v9772: (byte 0) */
  HW(3,0)
, 0
,};
Node CF_Data_46Sequence_46fromList[] = {
  VAPTAG(useLabel(FN_Data_46Sequence_46fromList))
, CAPTAG(useLabel(FN_Data_46List_46foldl_39),1)
, useLabel(F0_Data_46Sequence_46_124_62)
, useLabel(CF_Data_46Sequence_46empty)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v9799)
,	/* FN_Data_46Sequence_46splitDigit: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(29),BOT(29),TOP(102),BOT(102))
,	/* v9776: (byte 2) */
  bytes2word(TOP(233),BOT(233),UNPACK,1)
, bytes2word(HEAP_CVAL_N1,1,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,3)
, bytes2word(HEAP_P1,0,HEAP_OFF_N1,4)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG,2)
,	/* v9777: (byte 3) */
  bytes2word(HEAP_OFF_N1,6,RETURN_EVAL,UNPACK)
, bytes2word(2,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_OFF_N1,3,HEAP_I2)
, bytes2word(PUSH_P1,0,ZAP_ARG_I1,EVAL)
, bytes2word(PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32,LT_W)
, bytes2word(JUMPFALSE,21,0,HEAP_CVAL_N1)
, bytes2word(1,HEAP_CVAL_IN3,HEAP_P1,3)
, bytes2word(HEAP_CVAL_N1,4,HEAP_OFF_N1,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_OFF_N1)
, bytes2word(6,HEAP_P1,3,HEAP_OFF_N1)
,	/* v9778: (byte 2) */
  bytes2word(5,RETURN,PUSH_CVAL_P1,6)
, bytes2word(EVAL,NEEDHEAP_I32,JUMPFALSE,20)
, bytes2word(0,HEAP_CVAL_IN3,HEAP_I2,HEAP_CVAL_N1)
, bytes2word(4,HEAP_OFF_N1,3,HEAP_CVAL_N1)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_OFF_N1,4,HEAP_P1,4)
,	/* v9780: (byte 3) */
  bytes2word(HEAP_OFF_N1,4,RETURN,POP_P1)
,	/* v9782: (byte 4) */
  bytes2word(4,JUMP,68,1)
, bytes2word(UNPACK,3,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I4,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I5,HEAP_OFF_N1,3)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,4)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_I2)
, bytes2word(HEAP_OFF_N1,5,PUSH_P1,2)
, bytes2word(ZAP_ARG_I1,EVAL,PUSH_ARG_I2,EVAL)
, bytes2word(NEEDHEAP_I32,LT_W,JUMPFALSE,24)
, bytes2word(0,HEAP_CVAL_N1,1,HEAP_CVAL_N1)
, bytes2word(5,HEAP_P1,5,HEAP_P1)
, bytes2word(6,HEAP_CVAL_N1,4,HEAP_OFF_N1)
, bytes2word(4,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_OFF_N1,7,HEAP_P1,5)
,	/* v9783: (byte 3) */
  bytes2word(HEAP_OFF_N1,5,RETURN,PUSH_P1)
, bytes2word(0,EVAL,NEEDHEAP_I32,PUSH_ARG_I2)
, bytes2word(LT_W,JUMPFALSE,26,0)
, bytes2word(HEAP_CVAL_IN3,HEAP_P1,4,HEAP_CVAL_N1)
, bytes2word(4,HEAP_OFF_N1,3,HEAP_CVAL_IN3)
, bytes2word(HEAP_P1,6,HEAP_CVAL_N1,4)
, bytes2word(HEAP_OFF_N1,3,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,HEAP_OFF_N1,7,HEAP_P1)
,	/* v9785: (byte 4) */
  bytes2word(6,HEAP_OFF_N1,5,RETURN)
, bytes2word(PUSH_CVAL_P1,6,ZAP_ARG_I2,EVAL)
, bytes2word(NEEDHEAP_I32,JUMPFALSE,24,0)
, bytes2word(HEAP_CVAL_N1,5,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_CVAL_N1,4)
, bytes2word(HEAP_OFF_N1,4,HEAP_CVAL_N1,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_OFF_N1)
, bytes2word(4,HEAP_P1,7,HEAP_OFF_N1)
,	/* v9787: (byte 2) */
  bytes2word(4,RETURN,POP_P1,7)
,	/* v9789: (byte 3) */
  bytes2word(JUMP,193,0,UNPACK)
, bytes2word(4,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_OFF_N1,3,HEAP_I2)
, bytes2word(PUSH_HEAP,HEAP_ARG,1,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(3,HEAP_P1,4,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_I2,HEAP_OFF_N1)
, bytes2word(5,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,7)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_I2)
, bytes2word(HEAP_OFF_N1,5,PUSH_P1,4)
, bytes2word(ZAP_ARG_I1,EVAL,PUSH_ARG_I2,EVAL)
, bytes2word(NEEDHEAP_I32,LT_W,JUMPFALSE,26)
, bytes2word(0,HEAP_CVAL_N1,1,HEAP_CVAL_N1)
, bytes2word(6,HEAP_P1,7,HEAP_P1)
, bytes2word(8,HEAP_P1,9,HEAP_CVAL_N1)
, bytes2word(4,HEAP_OFF_N1,5,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,8)
, bytes2word(HEAP_P1,7,HEAP_OFF_N1,5)
,	/* v9790: (byte 1) */
  bytes2word(RETURN,PUSH_P1,2,EVAL)
, bytes2word(NEEDHEAP_I32,PUSH_ARG_I2,LT_W,JUMPFALSE)
, bytes2word(29,0,HEAP_CVAL_IN3,HEAP_P1)
, bytes2word(6,HEAP_CVAL_N1,4,HEAP_OFF_N1)
, bytes2word(3,HEAP_CVAL_N1,5,HEAP_P1)
, bytes2word(8,HEAP_P1,9,HEAP_CVAL_N1)
, bytes2word(4,HEAP_OFF_N1,4,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,8)
, bytes2word(HEAP_P1,8,HEAP_OFF_N1,5)
,	/* v9792: (byte 1) */
  bytes2word(RETURN,PUSH_P1,0,EVAL)
, bytes2word(NEEDHEAP_I32,PUSH_ARG_I2,LT_W,JUMPFALSE)
, bytes2word(29,0,HEAP_CVAL_N1,5)
, bytes2word(HEAP_P1,6,HEAP_P1,7)
, bytes2word(HEAP_CVAL_N1,4,HEAP_OFF_N1,4)
, bytes2word(HEAP_CVAL_IN3,HEAP_P1,9,HEAP_CVAL_N1)
, bytes2word(4,HEAP_OFF_N1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,7)
, bytes2word(HEAP_P1,9,HEAP_OFF_N1,5)
,	/* v9794: (byte 1) */
  bytes2word(RETURN,PUSH_CVAL_P1,6,ZAP_ARG_I2)
, bytes2word(EVAL,NEEDHEAP_I32,JUMPFALSE,26)
, bytes2word(0,HEAP_CVAL_N1,6,HEAP_P1)
, bytes2word(6,HEAP_P1,7,HEAP_P1)
, bytes2word(8,HEAP_CVAL_N1,4,HEAP_OFF_N1)
, bytes2word(5,HEAP_CVAL_N1,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,4)
, bytes2word(HEAP_P1,10,HEAP_OFF_N1,4)
,	/* v9796: (byte 1) */
  bytes2word(RETURN,POP_P1,10,JUMP)
,	/* v9773: (byte 2) */
  bytes2word(2,0,HEAP_CVAL_P1,8)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_OFF_N1)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(2,3,0)
, CONSTR(1,2,0)
, CONSTR(1,1,0)
, CONSTR(0,1,0)
, CONSTR(0,3,0)
, CONSTR(0,0,0)
,	/* CT_v9799: (byte 0) */
  HW(7,3)
, 0
,	/* F0_Data_46Sequence_46splitDigit: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46splitDigit),3)
, VAPTAG(useLabel(FN_Prelude_46seq))
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_LAMBDA9571))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v9801)
,	/* FN_LAMBDA9571: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v9800)
,	/* CT_v9801: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9571: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9571))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v9818)
,	/* FN_Data_46Sequence_46splitNode: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v9805: (byte 2) */
  bytes2word(TOP(79),BOT(79),UNPACK,3)
, bytes2word(PUSH_HEAP,HEAP_ARG,1,HEAP_CVAL_I3)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,3)
, bytes2word(PUSH_P1,0,ZAP_ARG_I1,EVAL)
, bytes2word(PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32,LT_W)
, bytes2word(JUMPFALSE,21,0,HEAP_CVAL_N1)
, bytes2word(1,HEAP_CVAL_N1,2,HEAP_P1)
, bytes2word(4,HEAP_CVAL_IN3,HEAP_OFF_N1,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,4,HEAP_OFF_N1)
, bytes2word(6,HEAP_P1,4,HEAP_OFF_N1)
,	/* v9806: (byte 2) */
  bytes2word(5,RETURN,PUSH_CVAL_P1,5)
, bytes2word(EVAL,NEEDHEAP_I32,JUMPFALSE,21)
, bytes2word(0,HEAP_CVAL_N1,2,HEAP_P1)
, bytes2word(3,HEAP_CVAL_IN3,HEAP_OFF_N1,3)
, bytes2word(HEAP_CVAL_N1,1,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(4,HEAP_OFF_N1,4,HEAP_P1)
,	/* v9808: (byte 4) */
  bytes2word(5,HEAP_OFF_N1,4,RETURN)
, bytes2word(POP_P1,5,JUMP,132)
,	/* v9810: (byte 1) */
  bytes2word(0,UNPACK,4,PUSH_HEAP)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I3,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I3,HEAP_P1)
, bytes2word(0,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_P1,5,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(6,HEAP_I2,HEAP_OFF_N1,5)
, bytes2word(PUSH_P1,2,ZAP_ARG_I1,EVAL)
, bytes2word(PUSH_ARG_I2,EVAL,NEEDHEAP_I32,LT_W)
, bytes2word(JUMPFALSE,23,0,HEAP_CVAL_N1)
, bytes2word(1,HEAP_CVAL_N1,5,HEAP_P1)
, bytes2word(6,HEAP_P1,7,HEAP_CVAL_IN3)
, bytes2word(HEAP_OFF_N1,4,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(4,HEAP_OFF_N1,7,HEAP_P1)
,	/* v9811: (byte 4) */
  bytes2word(6,HEAP_OFF_N1,5,RETURN)
, bytes2word(PUSH_P1,0,EVAL,NEEDHEAP_I32)
, bytes2word(PUSH_ARG_I2,LT_W,JUMPFALSE,26)
, bytes2word(0,HEAP_CVAL_N1,2,HEAP_P1)
, bytes2word(5,HEAP_CVAL_IN3,HEAP_OFF_N1,3)
, bytes2word(HEAP_CVAL_N1,2,HEAP_P1,7)
, bytes2word(HEAP_CVAL_IN3,HEAP_OFF_N1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,4,HEAP_OFF_N1,7)
, bytes2word(HEAP_P1,7,HEAP_OFF_N1,5)
,	/* v9813: (byte 1) */
  bytes2word(RETURN,PUSH_CVAL_P1,5,ZAP_ARG_I2)
, bytes2word(EVAL,NEEDHEAP_I32,JUMPFALSE,23)
, bytes2word(0,HEAP_CVAL_N1,5,HEAP_P1)
, bytes2word(5,HEAP_P1,6,HEAP_CVAL_IN3)
, bytes2word(HEAP_OFF_N1,4,HEAP_CVAL_N1,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,4,HEAP_OFF_N1)
, bytes2word(4,HEAP_P1,8,HEAP_OFF_N1)
,	/* v9815: (byte 2) */
  bytes2word(4,RETURN,POP_P1,8)
,	/* v9802: (byte 3) */
  bytes2word(JUMP,2,0,HEAP_CVAL_P1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,2,0)
, CONSTR(0,3,0)
, CONSTR(1,1,0)
, CONSTR(0,1,0)
, CONSTR(0,0,0)
,	/* CT_v9818: (byte 0) */
  HW(6,3)
, 0
,	/* F0_Data_46Sequence_46splitNode: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46splitNode),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_LAMBDA9572))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v9820)
,	/* FN_LAMBDA9572: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v9819)
,	/* CT_v9820: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9572: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9572))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v9827)
,	/* FN_Data_46Sequence_46digitToTree: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(15),BOT(15),TOP(36),BOT(36))
,	/* v9822: (byte 2) */
  bytes2word(TOP(58),BOT(58),UNPACK,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_I1)
,	/* v9823: (byte 1) */
  bytes2word(RETURN,UNPACK,2,HEAP_CVAL_N1)
, bytes2word(2,HEAP_P1,0,HEAP_CVAL_IN3)
, bytes2word(HEAP_CVAL_N1,2,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(7,HEAP_OFF_N1,6,HEAP_OFF_N1)
,	/* v9824: (byte 2) */
  bytes2word(6,RETURN_EVAL,UNPACK,3)
, bytes2word(HEAP_CVAL_N1,4,HEAP_P1,0)
, bytes2word(HEAP_I1,HEAP_CVAL_IN3,HEAP_CVAL_N1,2)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,8,HEAP_OFF_N1)
,	/* v9825: (byte 4) */
  bytes2word(6,HEAP_OFF_N1,6,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_N1,4)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_CVAL_IN3)
, bytes2word(HEAP_CVAL_N1,4,HEAP_I2,HEAP_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,9,HEAP_OFF_N1)
, bytes2word(7,HEAP_OFF_N1,7,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, CONSTR(1,2,0)
, CONSTR(0,0,0)
, CONSTR(0,1,0)
, CONSTR(1,1,0)
,	/* CT_v9827: (byte 0) */
  HW(1,2)
, 0
,	/* F0_Data_46Sequence_46digitToTree: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46digitToTree),2)
, VAPTAG(useLabel(FN_Data_46Sequence_46deep))
, bytes2word(1,0,0,1)
, useLabel(CT_v9832)
,	/* FN_Data_46Sequence_46nodeToDigit: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v9829: (byte 2) */
  bytes2word(TOP(13),BOT(13),UNPACK,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_I2)
,	/* v9830: (byte 3) */
  bytes2word(HEAP_P1,3,RETURN,UNPACK)
, bytes2word(4,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_I2,HEAP_P1,3,HEAP_P1)
, bytes2word(4,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(2,3,0)
, CONSTR(1,2,0)
,	/* CT_v9832: (byte 0) */
  HW(0,1)
, 0
,	/* F0_Data_46Sequence_46nodeToDigit: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46nodeToDigit),1)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v9844)
,	/* FN_Data_46Sequence_46viewRTree: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v9834: (byte 4) */
  bytes2word(TOP(11),BOT(11),TOP(22),BOT(22))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v9835: (byte 1) */
  bytes2word(RETURN,UNPACK,1,HEAP_CVAL_N1)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,2)
,	/* v9836: (byte 4) */
  bytes2word(HEAP_OFF_N1,2,HEAP_I1,RETURN)
, bytes2word(UNPACK,4,PUSH_P1,3)
, bytes2word(ZAP_STACK_P1,4,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(26),BOT(26),TOP(46),BOT(46))
,	/* v9838: (byte 2) */
  bytes2word(TOP(69),BOT(69),UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_I1,HEAP_ARG,1)
, bytes2word(HEAP_P1,0,HEAP_I2,HEAP_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_N1,2)
,	/* v9839: (byte 4) */
  bytes2word(HEAP_OFF_N1,7,HEAP_I1,RETURN)
, bytes2word(UNPACK,2,HEAP_CVAL_I4,HEAP_I2)
, bytes2word(HEAP_ARG,1,HEAP_I1,HEAP_P1)
, bytes2word(3,HEAP_P1,4,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_N1,2)
,	/* v9840: (byte 4) */
  bytes2word(HEAP_OFF_N1,8,HEAP_I2,RETURN)
, bytes2word(UNPACK,3,HEAP_CVAL_I5,HEAP_P1)
, bytes2word(3,HEAP_ARG,1,HEAP_I2)
, bytes2word(HEAP_P1,4,HEAP_P1,5)
, bytes2word(HEAP_P1,0,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,9)
,	/* v9841: (byte 3) */
  bytes2word(HEAP_P1,3,RETURN,UNPACK)
, bytes2word(4,HEAP_CVAL_P1,6,HEAP_P1)
, bytes2word(4,HEAP_ARG,1,HEAP_P1)
, bytes2word(3,HEAP_P1,5,HEAP_P1)
, bytes2word(6,HEAP_P1,0,HEAP_I1)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_OFF_N1,10,HEAP_P1,4)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTR(1,2,0)
, CONSTR(0,0,0)
,	/* CT_v9844: (byte 0) */
  HW(4,2)
, 0
,	/* F0_Data_46Sequence_46viewRTree: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46viewRTree),2)
, VAPTAG(useLabel(FN_LAMBDA9573))
, VAPTAG(useLabel(FN_LAMBDA9574))
, VAPTAG(useLabel(FN_LAMBDA9575))
, VAPTAG(useLabel(FN_LAMBDA9576))
, bytes2word(0,0,8,0)
, bytes2word(7,1,6,2)
, bytes2word(5,3,4,4)
, bytes2word(3,5,2,6)
, bytes2word(1,7,0,8)
, useLabel(CT_v9845)
,	/* FN_LAMBDA9576: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,6,7,HEAP_ARG)
, bytes2word(8,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG_ARG,4)
, bytes2word(5,HEAP_OFF_N1,8,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, CONSTR(2,4,0)
, CONSTR(2,3,0)
,	/* CT_v9845: (byte 0) */
  HW(3,8)
, 0
,	/* F0_LAMBDA9576: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9576),8)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, bytes2word(7,0,6,1)
, bytes2word(5,2,4,3)
, bytes2word(3,4,2,5)
, bytes2word(1,6,0,7)
, useLabel(CT_v9846)
,	/* FN_LAMBDA9575: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,6,7,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,7)
, bytes2word(HEAP_ARG_ARG,4,5,HEAP_OFF_N1)
, bytes2word(7,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(2,4,0)
, CONSTR(1,2,0)
,	/* CT_v9846: (byte 0) */
  HW(3,7)
, 0
,	/* F0_LAMBDA9575: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9575),7)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, bytes2word(0,0,6,0)
, bytes2word(5,1,4,2)
, bytes2word(3,3,2,4)
, bytes2word(1,5,0,6)
, useLabel(CT_v9847)
,	/* FN_LAMBDA9574: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG,6,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,HEAP_OFF_N1,6,HEAP_ARG_ARG)
, bytes2word(4,5,HEAP_OFF_N1,6)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTR(2,4,0)
, CONSTR(0,1,0)
,	/* CT_v9847: (byte 0) */
  HW(3,6)
, 0
,	/* F0_LAMBDA9574: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9574),6)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, bytes2word(5,0,4,1)
, bytes2word(3,2,2,3)
, bytes2word(1,4,0,5)
, useLabel(CT_v9852)
,	/* FN_LAMBDA9573: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,5,ZAP_ARG,5)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v9849: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(10),BOT(10))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG_ARG_RET_EVAL)
,	/* v9850: (byte 2) */
  bytes2word(2,4,UNPACK,2)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,5)
, bytes2word(HEAP_CVAL_P1,9,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_OFF_N1,6)
, bytes2word(HEAP_ARG,4,HEAP_I1,HEAP_OFF_N1)
, bytes2word(6,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
,	/* CT_v9852: (byte 0) */
  HW(7,5)
, 0
,	/* F0_LAMBDA9573: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9573),5)
, VAPTAG(useLabel(FN_Data_46Sequence_46viewRTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46digitToTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Data_46Sequence_46nodeToDigit))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v9861)
,	/* FN_Data_46Sequence_46deepR: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG,4,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,2,NOP)
,	/* v9854: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(39),BOT(39))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v9856: (byte 2) */
  bytes2word(TOP(10),BOT(10),POP_I1,PUSH_HEAP)
,	/* v9857: (byte 4) */
  bytes2word(HEAP_CVAL_I5,HEAP_ARG_ARG_RET_EVAL,1,2)
, bytes2word(UNPACK,2,HEAP_CVAL_P1,6)
, bytes2word(HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_I1)
,	/* v9858: (byte 3) */
  bytes2word(HEAP_OFF_N1,6,RETURN_EVAL,UNPACK)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,HEAP_I1,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v9861: (byte 0) */
  HW(5,4)
, 0
,	/* F0_Data_46Sequence_46deepR: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46deepR),4)
, VAPTAG(useLabel(FN_Data_46Sequence_46viewRTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46digitToTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46nodeToDigit))
, VAPTAG(useLabel(FN_Data_46Sequence_46deep))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v9873)
,	/* FN_Data_46Sequence_46viewLTree: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v9863: (byte 4) */
  bytes2word(TOP(11),BOT(11),TOP(22),BOT(22))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v9864: (byte 1) */
  bytes2word(RETURN,UNPACK,1,HEAP_CVAL_N1)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,2)
,	/* v9865: (byte 4) */
  bytes2word(HEAP_I1,HEAP_OFF_N1,3,RETURN)
, bytes2word(UNPACK,4,PUSH_I1,ZAP_STACK_P1)
, bytes2word(2,EVAL,NEEDHEAP_I32,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(27),BOT(27),TOP(47),BOT(47))
,	/* v9867: (byte 2) */
  bytes2word(TOP(69),BOT(69),UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_I1,HEAP_ARG,1)
, bytes2word(HEAP_P1,0,HEAP_P1,4)
, bytes2word(HEAP_P1,3,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,HEAP_I1,HEAP_OFF_N1,8)
,	/* v9868: (byte 1) */
  bytes2word(RETURN,UNPACK,2,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_ARG,1,HEAP_P1)
, bytes2word(0,HEAP_I1,HEAP_P1,4)
, bytes2word(HEAP_P1,5,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,HEAP_I1,HEAP_OFF_N1,9)
,	/* v9869: (byte 1) */
  bytes2word(RETURN,UNPACK,3,HEAP_CVAL_I5)
, bytes2word(HEAP_P1,3,HEAP_ARG,1)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_I2)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_I1)
,	/* v9870: (byte 3) */
  bytes2word(HEAP_OFF_N1,10,RETURN,UNPACK)
, bytes2word(4,HEAP_CVAL_P1,6,HEAP_P1)
, bytes2word(4,HEAP_ARG,1,HEAP_P1)
, bytes2word(0,HEAP_I1,HEAP_I2,HEAP_P1)
, bytes2word(3,HEAP_P1,6,HEAP_P1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_I1,HEAP_OFF_N1,11,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, CONSTR(1,2,0)
, CONSTR(0,0,0)
,	/* CT_v9873: (byte 0) */
  HW(4,2)
, 0
,	/* F0_Data_46Sequence_46viewLTree: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46viewLTree),2)
, VAPTAG(useLabel(FN_LAMBDA9577))
, VAPTAG(useLabel(FN_LAMBDA9578))
, VAPTAG(useLabel(FN_LAMBDA9579))
, VAPTAG(useLabel(FN_LAMBDA9580))
, bytes2word(0,0,8,0)
, bytes2word(7,1,6,2)
, bytes2word(5,3,4,4)
, bytes2word(3,5,2,6)
, bytes2word(1,7,0,8)
, useLabel(CT_v9874)
,	/* FN_LAMBDA9580: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,4,5,HEAP_ARG)
, bytes2word(6,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_OFF_N1,8,HEAP_OFF_N1,6)
, bytes2word(HEAP_ARG_ARG,7,8,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, CONSTR(2,4,0)
, CONSTR(2,3,0)
,	/* CT_v9874: (byte 0) */
  HW(3,8)
, 0
,	/* F0_LAMBDA9580: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9580),8)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, bytes2word(7,0,6,1)
, bytes2word(5,2,4,3)
, bytes2word(3,4,2,5)
, bytes2word(1,6,0,7)
, useLabel(CT_v9875)
,	/* FN_LAMBDA9579: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,4,5,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,7)
, bytes2word(HEAP_OFF_N1,5,HEAP_ARG_ARG,6)
, bytes2word(7,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(2,4,0)
, CONSTR(1,2,0)
,	/* CT_v9875: (byte 0) */
  HW(3,7)
, 0
,	/* F0_LAMBDA9579: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9579),7)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, bytes2word(0,0,6,0)
, bytes2word(5,1,4,2)
, bytes2word(3,3,2,4)
, bytes2word(1,5,0,6)
, useLabel(CT_v9876)
,	/* FN_LAMBDA9578: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG,4,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,HEAP_OFF_N1,6,HEAP_OFF_N1)
, bytes2word(4,HEAP_ARG_ARG,5,6)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTR(2,4,0)
, CONSTR(0,1,0)
,	/* CT_v9876: (byte 0) */
  HW(3,6)
, 0
,	/* F0_LAMBDA9578: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9578),6)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, bytes2word(5,0,4,1)
, bytes2word(3,2,2,3)
, bytes2word(1,4,0,5)
, useLabel(CT_v9881)
,	/* FN_LAMBDA9577: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,5,ZAP_ARG,5)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v9878: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(10),BOT(10))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG_ARG_RET_EVAL)
,	/* v9879: (byte 2) */
  bytes2word(2,4,UNPACK,2)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,5)
, bytes2word(HEAP_CVAL_P1,9,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_OFF_N1)
, bytes2word(6,HEAP_OFF_N1,4,HEAP_I2)
, bytes2word(HEAP_ARG,4,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
,	/* CT_v9881: (byte 0) */
  HW(7,5)
, 0
,	/* F0_LAMBDA9577: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9577),5)
, VAPTAG(useLabel(FN_Data_46Sequence_46viewLTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46digitToTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Data_46Sequence_46nodeToDigit))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v9890)
,	/* FN_Data_46Sequence_46deepL: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v9883: (byte 2) */
  bytes2word(TOP(41),BOT(41),POP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG,3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v9885: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(10),BOT(10))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG_ARG_RET_EVAL)
,	/* v9886: (byte 2) */
  bytes2word(1,4,UNPACK,2)
, bytes2word(HEAP_CVAL_P1,6,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,4,HEAP_I2)
,	/* v9887: (byte 3) */
  bytes2word(HEAP_ARG,4,RETURN_EVAL,UNPACK)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_I1,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(3,4,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v9890: (byte 0) */
  HW(5,4)
, 0
,	/* F0_Data_46Sequence_46deepL: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46deepL),4)
, VAPTAG(useLabel(FN_Data_46Sequence_46viewLTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46digitToTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46nodeToDigit))
, VAPTAG(useLabel(FN_Data_46Sequence_46deep))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v9916)
,	/* FN_Data_46Sequence_46splitTree: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v9894: (byte 4) */
  bytes2word(TOP(13),BOT(13),TOP(34),BOT(34))
, bytes2word(POP_I1,HEAP_CVAL_I3,PUSH_HEAP,HEAP_CVAL_I4)
,	/* v9895: (byte 3) */
  bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,UNPACK)
, bytes2word(1,HEAP_CVAL_N1,1,HEAP_CVAL_N1)
, bytes2word(1,HEAP_CVAL_N1,2,HEAP_OFF_N1)
, bytes2word(3,HEAP_P1,0,HEAP_OFF_N1)
, bytes2word(4,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
,	/* v9896: (byte 4) */
  bytes2word(2,HEAP_OFF_N1,6,RETURN_EVAL)
, bytes2word(UNPACK,4,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_I1,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,2)
, bytes2word(HEAP_I1,HEAP_CVAL_P1,8,HEAP_CVAL_P1)
, bytes2word(9,HEAP_P1,5,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,10,HEAP_I2,HEAP_OFF_N1)
, bytes2word(5,PUSH_P1,2,EVAL)
, bytes2word(PUSH_ARG_I2,EVAL,NEEDHEAP_I32,LT_W)
, bytes2word(JUMPFALSE,46,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,11,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_P1,6,EVAL)
, bytes2word(NEEDHEAP_I32,UNPACK,3,HEAP_CVAL_N1)
, bytes2word(1,HEAP_CVAL_P1,12,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_P1,13,HEAP_OFF_N1)
, bytes2word(4,HEAP_OFF_N1,4,HEAP_P1)
, bytes2word(0,HEAP_CVAL_P1,14,HEAP_ARG)
, bytes2word(1,HEAP_I2,HEAP_P1,9)
, bytes2word(HEAP_P1,10,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,HEAP_OFF_N1,10,HEAP_I2)
,	/* v9897: (byte 3) */
  bytes2word(HEAP_OFF_N1,8,RETURN,PUSH_P1)
, bytes2word(0,EVAL,NEEDHEAP_I32,PUSH_ARG_I2)
, bytes2word(LT_W,JUMPFALSE,68,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,15,HEAP_CVAL_P1)
, bytes2word(9,HEAP_I2,HEAP_P1,7)
, bytes2word(EVAL,NEEDHEAP_I32,UNPACK,3)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_P1,9)
, bytes2word(HEAP_P1,0,HEAP_CVAL_P1,7)
, bytes2word(HEAP_P1,4,HEAP_OFF_N1,5)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,16,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,5,HEAP_I2)
, bytes2word(ZAP_STACK_P1,2,EVAL,NEEDHEAP_I32)
, bytes2word(UNPACK,3,HEAP_CVAL_P1,17)
, bytes2word(HEAP_ARG,1,HEAP_P1,11)
, bytes2word(HEAP_P1,3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,14,HEAP_ARG,1)
, bytes2word(HEAP_I2,HEAP_P1,5,HEAP_P1)
, bytes2word(13,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_OFF_N1,11,HEAP_I2,HEAP_OFF_N1)
,	/* v9901: (byte 2) */
  bytes2word(8,RETURN,PUSH_CVAL_P1,18)
, bytes2word(EVAL,NEEDHEAP_I32,JUMPFALSE,54)
, bytes2word(0,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(2,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,11,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,5,HEAP_P1,8)
, bytes2word(ZAP_ARG_I2,EVAL,NEEDHEAP_I32,UNPACK)
, bytes2word(3,HEAP_CVAL_P1,17,HEAP_ARG)
, bytes2word(1,HEAP_P1,8,HEAP_P1)
, bytes2word(9,HEAP_P1,0,HEAP_CVAL_N1)
, bytes2word(1,HEAP_CVAL_P1,12,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_P1,13,HEAP_OFF_N1)
, bytes2word(4,HEAP_OFF_N1,4,HEAP_I2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_OFF_N1)
, bytes2word(13,HEAP_I2,HEAP_OFF_N1,7)
,	/* v9907: (byte 1) */
  bytes2word(RETURN,POP_P1,8,JUMP)
,	/* v9891: (byte 2) */
  bytes2word(2,0,HEAP_CVAL_P1,19)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,20,HEAP_OFF_N1)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(0,3,0)
, CONSTR(0,0,0)
,	/* CT_v9916: (byte 0) */
  HW(18,3)
, 0
,	/* F0_Data_46Sequence_46splitTree: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46splitTree),3)
, VAPTAG(useLabel(FN_LAMBDA9581))
, VAPTAG(useLabel(FN_Prelude_46error))
, VAPTAG(useLabel(FN_Prelude_46seq))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit_46size))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46splitDigit))
, CAPTAG(useLabel(FN_Data_46Sequence_46digitToTree),1)
, VAPTAG(useLabel(FN_Prelude_46maybe))
, VAPTAG(useLabel(FN_Data_46Sequence_46deepL))
, VAPTAG(useLabel(FN_Data_46Sequence_46splitTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46splitNode))
, VAPTAG(useLabel(FN_Data_46Sequence_46deepR))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_LAMBDA9582))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v9918)
,	/* FN_LAMBDA9582: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v9917)
,	/* CT_v9918: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9582: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9582))
, bytes2word(0,0,0,0)
, useLabel(CT_v9920)
,	/* FN_LAMBDA9581: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v9919)
,	/* CT_v9920: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9581: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9581))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v9932)
,	/* FN_Data_46Sequence_46consTree: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v9922: (byte 4) */
  bytes2word(TOP(13),BOT(13),TOP(35),BOT(35))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v9923: (byte 3) */
  bytes2word(HEAP_ARG,2,RETURN,UNPACK)
, bytes2word(1,HEAP_CVAL_N1,2,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_IN3,HEAP_CVAL_N1,2)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,7)
, bytes2word(HEAP_OFF_N1,6,HEAP_OFF_N1,6)
,	/* v9924: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,PUSH_I1)
, bytes2word(ZAP_STACK_P1,2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(41),BOT(41),TOP(75),BOT(75))
,	/* v9926: (byte 2) */
  bytes2word(TOP(111),BOT(111),UNPACK,1)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_P1,6,HEAP_OFF_N1,4)
, bytes2word(HEAP_I1,HEAP_CVAL_N1,4,HEAP_ARG)
, bytes2word(2,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,5,HEAP_OFF_N1,7)
, bytes2word(HEAP_OFF_N1,5,HEAP_P1,4)
,	/* v9927: (byte 3) */
  bytes2word(HEAP_P1,5,RETURN,UNPACK)
, bytes2word(2,HEAP_CVAL_I4,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I5,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_P1,6,HEAP_OFF_N1)
, bytes2word(4,HEAP_I2,HEAP_CVAL_N1,6)
, bytes2word(HEAP_ARG,2,HEAP_P1,0)
, bytes2word(HEAP_I1,PUSH_HEAP,HEAP_CVAL_N1,5)
, bytes2word(HEAP_OFF_N1,8,HEAP_OFF_N1,6)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
,	/* v9928: (byte 1) */
  bytes2word(RETURN,UNPACK,3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(3,HEAP_ARG,2,HEAP_CVAL_P1)
, bytes2word(6,HEAP_OFF_N1,4,HEAP_P1)
, bytes2word(3,HEAP_CVAL_N1,7,HEAP_ARG)
, bytes2word(2,HEAP_P1,0,HEAP_I1)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_N1,5)
, bytes2word(HEAP_OFF_N1,9,HEAP_OFF_N1,7)
, bytes2word(HEAP_P1,6,HEAP_P1,7)
,	/* v9929: (byte 1) */
  bytes2word(RETURN,UNPACK,4,HEAP_CVAL_P1)
, bytes2word(7,HEAP_P1,4,HEAP_ARG)
, bytes2word(2,HEAP_P1,0,HEAP_ARG)
, bytes2word(1,HEAP_I1,HEAP_I2,HEAP_P1)
, bytes2word(3,HEAP_P1,6,HEAP_P1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_P1,7,HEAP_OFF_N1,12)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(3,4,0)
, CONSTR(2,3,0)
, CONSTR(2,4,0)
, CONSTR(1,2,0)
, CONSTR(0,0,0)
, CONSTR(0,1,0)
, CONSTR(1,1,0)
,	/* CT_v9932: (byte 0) */
  HW(6,3)
, 0
,	/* F0_Data_46Sequence_46consTree: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46consTree),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46deep))
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_LAMBDA9583))
, VAPTAG(useLabel(FN_Prelude_46seq))
, bytes2word(9,0,8,1)
, bytes2word(7,2,6,3)
, bytes2word(5,4,4,5)
, bytes2word(3,6,2,7)
, bytes2word(1,8,0,9)
, useLabel(CT_v9933)
,	/* FN_LAMBDA9583: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,4)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_I5,HEAP_OFF_N1,4)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,2,3,HEAP_CVAL_P1)
, bytes2word(6,HEAP_ARG_ARG,4,5)
, bytes2word(HEAP_ARG_ARG,6,7,HEAP_CVAL_P1)
, bytes2word(7,HEAP_CVAL_P1,8,HEAP_OFF_N1)
, bytes2word(7,HEAP_ARG,8,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,16)
, bytes2word(HEAP_OFF_N1,14,HEAP_OFF_N1,7)
, bytes2word(HEAP_ARG,9,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(2,4,0)
, CONSTR(1,2,0)
,	/* CT_v9933: (byte 0) */
  HW(6,9)
, 0
,	/* F0_LAMBDA9583: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9583),9)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46node3))
, VAPTAG(useLabel(FN_Data_46Sequence_46consTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v9943)
,	/* FN_Data_46Sequence_46split: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(10),BOT(10))
,	/* v9942: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v9937: (byte 4) */
  bytes2word(POP_I1,JUMP,20,0)
, bytes2word(POP_I1,HEAP_CVAL_N1,1,HEAP_CVAL_N1)
, bytes2word(1,HEAP_CVAL_N1,2,HEAP_OFF_N1)
, bytes2word(3,HEAP_OFF_N1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_OFF_N1)
,	/* v9934: (byte 2) */
  bytes2word(5,RETURN_EVAL,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG_ARG,1,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,6,HEAP_OFF_N1)
, bytes2word(5,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,7,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_OFF_N1,9,PUSH_ZAP_ARG_I1)
, bytes2word(ZAP_STACK_P1,4,EVAL,NEEDHEAP_I32)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,2,EVAL,NEEDHEAP_I32)
, bytes2word(GT_W,JUMPFALSE,16,0)
, bytes2word(HEAP_CVAL_P1,10,HEAP_CVAL_I5,HEAP_I1)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,HEAP_P1,3,HEAP_OFF_N1)
,	/* v9938: (byte 2) */
  bytes2word(6,RETURN,PUSH_CVAL_P1,11)
, bytes2word(ZAP_STACK_P1,3,ZAP_STACK_P1,2)
, bytes2word(EVAL,NEEDHEAP_I32,JUMPFALSE,12)
, bytes2word(0,HEAP_CVAL_N1,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_ARG,2)
,	/* v9940: (byte 3) */
  bytes2word(HEAP_OFF_N1,3,RETURN,HEAP_CVAL_P1)
, bytes2word(12,PUSH_HEAP,HEAP_CVAL_P1,13)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, CONSTR(0,2,0)
, CONSTR(0,0,0)
,	/* CT_v9943: (byte 0) */
  HW(11,2)
, 0
,	/* F0_Data_46Sequence_46split: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46split),2)
, VAPTAG(useLabel(FN_Prelude_46seq))
, VAPTAG(useLabel(FN_Data_46Sequence_46splitTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, VAPTAG(useLabel(FN_LAMBDA9584))
, VAPTAG(useLabel(FN_LAMBDA9585))
, VAPTAG(useLabel(FN_LAMBDA9586))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size))
, VAPTAG(useLabel(FN_Data_46Sequence_46consTree))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_LAMBDA9587))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v9945)
,	/* FN_LAMBDA9587: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v9944)
,	/* CT_v9945: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9587: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9587))
, bytes2word(1,0,0,1)
, useLabel(CT_v9946)
,	/* FN_LAMBDA9586: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,3)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v9946: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA9586: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9586),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v9947)
,	/* FN_LAMBDA9585: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v9947: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA9585: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9585),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v9948)
,	/* FN_LAMBDA9584: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,1)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v9948: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA9584: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9584),1)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v9949)
,};
Node FN_Data_46Sequence_46splitAt[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,2,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,4,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,6,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_I2,HEAP_I1,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v9949: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_Data_46Sequence_46splitAt[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46splitAt),2)
, VAPTAG(useLabel(FN_Data_46Sequence_46split))
, VAPTAG(useLabel(FN_LAMBDA9588))
, VAPTAG(useLabel(FN_LAMBDA9589))
, bytes2word(1,0,0,1)
, useLabel(CT_v9950)
,	/* FN_LAMBDA9589: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,2)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v9950: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA9589: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9589),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v9951)
,	/* FN_LAMBDA9588: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,1)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v9951: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA9588: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9588),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v9952)
,};
Node FN_Data_46Sequence_46drop[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(4,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v9952: (byte 0) */
  HW(3,1)
, 0
,};
Node F0_Data_46Sequence_46drop[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46drop),1)
, CAPTAG(useLabel(FN_Data_46Sequence_46splitAt),1)
, VAPTAG(useLabel(FN_Prelude_46_46))
, useLabel(F0_Prelude_46snd)
, bytes2word(1,0,0,1)
, useLabel(CT_v9953)
,};
Node FN_Data_46Sequence_46take[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(4,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v9953: (byte 0) */
  HW(3,1)
, 0
,};
Node F0_Data_46Sequence_46take[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46take),1)
, CAPTAG(useLabel(FN_Data_46Sequence_46splitAt),1)
, VAPTAG(useLabel(FN_Prelude_46_46))
, useLabel(F0_Prelude_46fst)
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v9980)
,	/* FN_Data_46Sequence_46adjustDigit: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG,4,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,4,NOP)
, bytes2word(TOP(8),BOT(8),TOP(22),BOT(22))
,	/* v9957: (byte 4) */
  bytes2word(TOP(92),BOT(92),TOP(212),BOT(212))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(2,3,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_OFF_N1)
,	/* v9958: (byte 2) */
  bytes2word(5,RETURN,UNPACK,2)
, bytes2word(PUSH_HEAP,HEAP_ARG,1,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_I2,PUSH_P1)
, bytes2word(0,ZAP_ARG_I1,EVAL,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,LT_W,JUMPFALSE)
, bytes2word(15,0,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(2,3,HEAP_I2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_OFF_N1,5)
,	/* v9959: (byte 3) */
  bytes2word(HEAP_P1,4,RETURN,PUSH_CVAL_P1)
, bytes2word(6,EVAL,NEEDHEAP_I32,JUMPFALSE)
, bytes2word(23,0,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(5,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_P1,3)
,	/* v9961: (byte 3) */
  bytes2word(HEAP_OFF_N1,6,RETURN,POP_P1)
,	/* v9963: (byte 4) */
  bytes2word(4,JUMP,46,1)
, bytes2word(UNPACK,3,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I4,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I5,HEAP_OFF_N1,3)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,4)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_I2)
, bytes2word(HEAP_OFF_N1,5,PUSH_P1,2)
, bytes2word(ZAP_ARG_I1,EVAL,PUSH_ARG_I3,EVAL)
, bytes2word(NEEDHEAP_I32,LT_W,JUMPFALSE,17)
, bytes2word(0,HEAP_CVAL_I3,HEAP_ARG_ARG,2)
, bytes2word(3,HEAP_P1,4,PUSH_HEAP)
, bytes2word(HEAP_CVAL_IN3,HEAP_OFF_N1,5,HEAP_P1)
,	/* v9964: (byte 4) */
  bytes2word(6,HEAP_P1,7,RETURN)
, bytes2word(PUSH_P1,0,EVAL,NEEDHEAP_I32)
, bytes2word(PUSH_ARG_I3,LT_W,JUMPFALSE,23)
, bytes2word(0,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(3,HEAP_I2,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(2,HEAP_OFF_N1,5,HEAP_P1)
, bytes2word(5,PUSH_HEAP,HEAP_CVAL_IN3,HEAP_P1)
, bytes2word(5,HEAP_OFF_N1,6,HEAP_P1)
,	/* v9966: (byte 2) */
  bytes2word(7,RETURN,PUSH_CVAL_P1,6)
, bytes2word(EVAL,NEEDHEAP_I32,JUMPFALSE,24)
, bytes2word(0,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(3,HEAP_P1,0,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,2,HEAP_OFF_N1,5)
, bytes2word(HEAP_P1,6,PUSH_HEAP,HEAP_CVAL_IN3)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
,	/* v9968: (byte 3) */
  bytes2word(HEAP_OFF_N1,7,RETURN,POP_P1)
,	/* v9970: (byte 4) */
  bytes2word(7,JUMP,182,0)
, bytes2word(UNPACK,4,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I4,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I5,HEAP_OFF_N1,3)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,4)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_I2)
, bytes2word(HEAP_OFF_N1,5,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I4,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I5,HEAP_OFF_N1,3,HEAP_P1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_I2,HEAP_OFF_N1,5,PUSH_P1)
, bytes2word(4,ZAP_ARG_I1,EVAL,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,LT_W,JUMPFALSE)
, bytes2word(20,0,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(2,3,HEAP_P1,6)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,4,HEAP_OFF_N1)
, bytes2word(5,HEAP_P1,8,HEAP_P1)
,	/* v9971: (byte 4) */
  bytes2word(9,HEAP_P1,10,RETURN)
, bytes2word(PUSH_P1,2,EVAL,NEEDHEAP_I32)
, bytes2word(PUSH_ARG_I3,LT_W,JUMPFALSE,27)
, bytes2word(0,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(3,HEAP_P1,4,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,2,HEAP_OFF_N1,5)
, bytes2word(HEAP_P1,7,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(4,HEAP_P1,7,HEAP_OFF_N1)
, bytes2word(6,HEAP_P1,9,HEAP_P1)
,	/* v9973: (byte 2) */
  bytes2word(10,RETURN,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,PUSH_ARG_I3,LT_W)
, bytes2word(JUMPFALSE,26,0,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,3,HEAP_I2)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(5,HEAP_P1,8,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,4,HEAP_P1,7)
, bytes2word(HEAP_P1,8,HEAP_OFF_N1,7)
,	/* v9975: (byte 3) */
  bytes2word(HEAP_P1,10,RETURN,PUSH_CVAL_P1)
, bytes2word(6,EVAL,NEEDHEAP_I32,JUMPFALSE)
, bytes2word(27,0,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(5,HEAP_P1,9,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,4,HEAP_P1,7)
, bytes2word(HEAP_P1,8,HEAP_P1,9)
,	/* v9977: (byte 3) */
  bytes2word(HEAP_OFF_N1,8,RETURN,POP_P1)
,	/* v9954: (byte 4) */
  bytes2word(10,JUMP,2,0)
, bytes2word(HEAP_CVAL_P1,9,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(10,HEAP_OFF_N1,2,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, CONSTR(3,4,0)
, CONSTR(2,3,0)
, CONSTR(1,2,0)
, CONSTR(0,1,0)
,	/* CT_v9980: (byte 0) */
  HW(8,4)
, 0
,	/* F0_Data_46Sequence_46adjustDigit: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46adjustDigit),4)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_LAMBDA9590))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v9982)
,	/* FN_LAMBDA9590: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v9981)
,	/* CT_v9982: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9590: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9590))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v9999)
,	/* FN_Data_46Sequence_46adjustNode: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG,4,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,2,NOP)
,	/* v9986: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(80),BOT(80))
, bytes2word(UNPACK,3,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I3,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_P1,3,PUSH_P1,0)
, bytes2word(ZAP_ARG_I1,EVAL,PUSH_ARG_I3,EVAL)
, bytes2word(NEEDHEAP_I32,LT_W,JUMPFALSE,18)
, bytes2word(0,HEAP_CVAL_I5,HEAP_ARG_ARG,2)
, bytes2word(3,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_P1,3)
, bytes2word(HEAP_OFF_N1,6,HEAP_P1,5)
,	/* v9987: (byte 1) */
  bytes2word(RETURN,PUSH_CVAL_P1,6,EVAL)
, bytes2word(NEEDHEAP_I32,JUMPFALSE,25,0)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,3)
, bytes2word(HEAP_P1,0,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(2,HEAP_OFF_N1,5,HEAP_P1)
, bytes2word(4,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
,	/* v9989: (byte 3) */
  bytes2word(HEAP_OFF_N1,7,RETURN,POP_P1)
,	/* v9991: (byte 4) */
  bytes2word(5,JUMP,132,0)
, bytes2word(UNPACK,4,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I3,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_P1,3,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_P1)
, bytes2word(5,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_I2,HEAP_OFF_N1,5,PUSH_P1)
, bytes2word(2,ZAP_ARG_I1,EVAL,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,LT_W,JUMPFALSE)
, bytes2word(20,0,HEAP_CVAL_I5,HEAP_ARG_ARG)
, bytes2word(2,3,HEAP_P1,5)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_P1)
, bytes2word(5,HEAP_OFF_N1,6,HEAP_P1)
,	/* v9992: (byte 4) */
  bytes2word(7,HEAP_P1,8,RETURN)
, bytes2word(PUSH_P1,0,EVAL,NEEDHEAP_I32)
, bytes2word(PUSH_ARG_I3,LT_W,JUMPFALSE,26)
, bytes2word(0,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(3,HEAP_I2,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(2,HEAP_OFF_N1,5,HEAP_P1)
, bytes2word(6,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
, bytes2word(HEAP_OFF_N1,7,HEAP_P1,8)
,	/* v9994: (byte 1) */
  bytes2word(RETURN,PUSH_CVAL_P1,6,EVAL)
, bytes2word(NEEDHEAP_I32,JUMPFALSE,27,0)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,3)
, bytes2word(HEAP_P1,0,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(2,HEAP_OFF_N1,5,HEAP_P1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
, bytes2word(HEAP_P1,7,HEAP_OFF_N1,8)
,	/* v9996: (byte 1) */
  bytes2word(RETURN,POP_P1,8,JUMP)
,	/* v9983: (byte 2) */
  bytes2word(2,0,HEAP_CVAL_P1,9)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_OFF_N1)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(1,4,0)
, CONSTR(0,3,0)
,	/* CT_v9999: (byte 0) */
  HW(8,4)
, 0
,	/* F0_Data_46Sequence_46adjustNode: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46adjustNode),4)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_LAMBDA9591))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10001)
,	/* FN_LAMBDA9591: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10000)
,	/* CT_v10001: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9591: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9591))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v10015)
,	/* FN_Data_46Sequence_46adjustTree: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG,4,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,3,NOP)
, bytes2word(TOP(6),BOT(6),TOP(13),BOT(13))
,	/* v10005: (byte 2) */
  bytes2word(TOP(27),BOT(27),POP_I1,HEAP_CVAL_I3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,2)
,	/* v10006: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,1,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG_ARG,2,3,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10007: (byte 3) */
  bytes2word(HEAP_OFF_N1,5,RETURN,UNPACK)
, bytes2word(4,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,6,HEAP_I1)
, bytes2word(HEAP_P1,3,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_P1,8,HEAP_P1,4)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_I1)
, bytes2word(HEAP_OFF_N1,5,PUSH_I1,EVAL)
, bytes2word(PUSH_ARG_I3,EVAL,NEEDHEAP_I32,LT_W)
, bytes2word(JUMPFALSE,23,0,HEAP_CVAL_P1)
, bytes2word(10,HEAP_ARG_ARG,1,2)
, bytes2word(HEAP_ARG,3,HEAP_P1,4)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_P1)
, bytes2word(4,HEAP_OFF_N1,7,HEAP_P1)
,	/* v10008: (byte 4) */
  bytes2word(6,HEAP_P1,7,RETURN)
, bytes2word(PUSH_P1,0,EVAL,NEEDHEAP_I32)
, bytes2word(PUSH_ARG_I3,LT_W,JUMPFALSE,34)
, bytes2word(0,HEAP_CVAL_P1,11,HEAP_ARG_ARG)
, bytes2word(1,2,HEAP_CVAL_P1,12)
, bytes2word(HEAP_ARG,3,HEAP_I1,HEAP_CVAL_P1)
, bytes2word(13,HEAP_CVAL_P1,8,HEAP_OFF_N1)
, bytes2word(8,HEAP_OFF_N1,6,HEAP_P1)
, bytes2word(5,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(HEAP_P1,4,HEAP_P1,5)
, bytes2word(HEAP_OFF_N1,8,HEAP_P1,7)
,	/* v10010: (byte 1) */
  bytes2word(RETURN,PUSH_CVAL_P1,14,EVAL)
, bytes2word(NEEDHEAP_I32,JUMPFALSE,29,0)
, bytes2word(HEAP_CVAL_P1,12,HEAP_ARG,3)
, bytes2word(HEAP_P1,0,HEAP_CVAL_P1,10)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_OFF_N1)
, bytes2word(6,HEAP_P1,6,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
,	/* v10012: (byte 3) */
  bytes2word(HEAP_OFF_N1,9,RETURN,POP_P1)
,	/* v10002: (byte 4) */
  bytes2word(7,JUMP,2,0)
, bytes2word(HEAP_CVAL_P1,15,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(16,HEAP_OFF_N1,2,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, CONSTR(2,4,0)
, CONSTR(1,1,0)
,	/* CT_v10015: (byte 0) */
  HW(14,4)
, 0
,	/* F0_Data_46Sequence_46adjustTree: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46adjustTree),4)
, VAPTAG(useLabel(FN_LAMBDA9592))
, VAPTAG(useLabel(FN_Prelude_46error))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit_46size))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46adjustDigit))
, CAPTAG(useLabel(FN_Data_46Sequence_46adjustNode),2)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Data_46Sequence_46adjustTree))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_LAMBDA9593))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10017)
,	/* FN_LAMBDA9593: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10016)
,	/* CT_v10017: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9593: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9593))
, bytes2word(0,0,0,0)
, useLabel(CT_v10019)
,	/* FN_LAMBDA9592: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10018)
,	/* CT_v10019: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9592: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9592))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10024)
,};
Node FN_Data_46Sequence_46adjust[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_INT_P1,0)
, bytes2word(HEAP_ARG,2,HEAP_CVAL_I4,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,2,HEAP_OFF_N1,5)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_OFF_N1)
, bytes2word(10,HEAP_OFF_N1,5,EVAL)
, bytes2word(NEEDHEAP_I32,JUMPFALSE,19,0)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_P1,9,HEAP_OFF_N1,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,4,HEAP_ARG_ARG_RET_EVAL,2)
,	/* v10020: (byte 1) */
  bytes2word(3,PUSH_CVAL_P1,11,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,EVAL,NEEDHEAP_I32,JUMPFALSE)
,	/* v10022: (byte 4) */
  bytes2word(4,0,PUSH_ARG_I3,RETURN_EVAL)
, bytes2word(HEAP_CVAL_P1,12,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(13,HEAP_OFF_N1,2,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10024: (byte 0) */
  HW(11,3)
, 0
,};
Node F0_Data_46Sequence_46adjust[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46adjust),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46_60_61))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46_60))
, VAPTAG(useLabel(FN_Prelude_46_38_38))
, CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Elem_46fmap),1)
, CAPTAG(useLabel(FN_Prelude_46const),1)
, VAPTAG(useLabel(FN_Data_46Sequence_46adjustTree))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_LAMBDA9594))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10026)
,	/* FN_LAMBDA9594: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10025)
,	/* CT_v10026: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9594: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9594))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10027)
,};
Node FN_Data_46Sequence_46update[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10027: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Sequence_46update[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46update),2)
, CAPTAG(useLabel(FN_Prelude_46const),1)
, CAPTAG(useLabel(FN_Data_46Sequence_46adjust),1)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10054)
,	/* FN_Data_46Sequence_46lookupDigit: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(17),BOT(17),TOP(75),BOT(75))
,	/* v10031: (byte 2) */
  bytes2word(TOP(172),BOT(172),UNPACK,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_ARG)
,	/* v10032: (byte 3) */
  bytes2word(2,HEAP_I1,RETURN,UNPACK)
, bytes2word(2,PUSH_HEAP,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I3,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_I2)
, bytes2word(PUSH_P1,0,ZAP_ARG_I1,EVAL)
, bytes2word(PUSH_ARG_I2,EVAL,NEEDHEAP_I32,LT_W)
, bytes2word(JUMPFALSE,10,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_ARG,2)
,	/* v10033: (byte 3) */
  bytes2word(HEAP_P1,3,RETURN,PUSH_CVAL_P1)
, bytes2word(5,EVAL,NEEDHEAP_I32,JUMPFALSE)
, bytes2word(16,0,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,2,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_OFF_N1)
,	/* v10035: (byte 4) */
  bytes2word(4,HEAP_P1,4,RETURN)
, bytes2word(POP_P1,4,JUMP,236)
,	/* v10037: (byte 1) */
  bytes2word(0,UNPACK,3,PUSH_HEAP)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I3,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,HEAP_I2,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_P1)
, bytes2word(4,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_I2,HEAP_OFF_N1,5,PUSH_P1)
, bytes2word(2,ZAP_ARG_I1,EVAL,PUSH_ARG_I2)
, bytes2word(EVAL,NEEDHEAP_I32,LT_W,JUMPFALSE)
, bytes2word(10,0,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_ARG,2,HEAP_P1)
,	/* v10038: (byte 2) */
  bytes2word(5,RETURN,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,PUSH_ARG_I2,LT_W)
, bytes2word(JUMPFALSE,15,0,HEAP_CVAL_P1)
, bytes2word(6,HEAP_ARG,2,HEAP_I2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_OFF_N1)
,	/* v10040: (byte 4) */
  bytes2word(4,HEAP_P1,6,RETURN)
, bytes2word(PUSH_CVAL_P1,5,EVAL,NEEDHEAP_I32)
, bytes2word(JUMPFALSE,16,0,HEAP_CVAL_P1)
, bytes2word(6,HEAP_ARG,2,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_OFF_N1,4,HEAP_P1,7)
,	/* v10042: (byte 1) */
  bytes2word(RETURN,POP_P1,7,JUMP)
,	/* v10044: (byte 2) */
  bytes2word(139,0,UNPACK,4)
, bytes2word(PUSH_HEAP,HEAP_ARG,1,HEAP_CVAL_I3)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,3,HEAP_I2,PUSH_HEAP)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I3,HEAP_P1)
, bytes2word(0,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_P1,4,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_I2,HEAP_OFF_N1,5)
, bytes2word(PUSH_HEAP,HEAP_ARG,1,HEAP_CVAL_I3)
, bytes2word(HEAP_P1,0,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,HEAP_P1,7,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_I2,HEAP_OFF_N1)
, bytes2word(5,PUSH_P1,4,ZAP_ARG_I1)
, bytes2word(EVAL,PUSH_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(LT_W,JUMPFALSE,10,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_ARG)
,	/* v10045: (byte 4) */
  bytes2word(2,HEAP_P1,7,RETURN)
, bytes2word(PUSH_P1,2,EVAL,NEEDHEAP_I32)
, bytes2word(PUSH_ARG_I2,LT_W,JUMPFALSE,16)
, bytes2word(0,HEAP_CVAL_P1,6,HEAP_ARG)
, bytes2word(2,HEAP_P1,4,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_OFF_N1,4)
,	/* v10047: (byte 3) */
  bytes2word(HEAP_P1,8,RETURN,PUSH_P1)
, bytes2word(0,EVAL,NEEDHEAP_I32,PUSH_ARG_I2)
, bytes2word(LT_W,JUMPFALSE,15,0)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,2)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_OFF_N1,4,HEAP_P1,9)
,	/* v10049: (byte 1) */
  bytes2word(RETURN,PUSH_CVAL_P1,5,EVAL)
, bytes2word(NEEDHEAP_I32,JUMPFALSE,16,0)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,2)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_OFF_N1,4,HEAP_P1)
,	/* v10051: (byte 2) */
  bytes2word(10,RETURN,POP_P1,10)
,	/* v10028: (byte 3) */
  bytes2word(JUMP,2,0,HEAP_CVAL_P1)
, bytes2word(8,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v10054: (byte 0) */
  HW(7,3)
, 0
,	/* F0_Data_46Sequence_46lookupDigit: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46lookupDigit),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_LAMBDA9595))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10056)
,	/* FN_LAMBDA9595: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10055)
,	/* CT_v10056: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9595: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9595))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10073)
,	/* FN_Data_46Sequence_46lookupNode: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10060: (byte 2) */
  bytes2word(TOP(63),BOT(63),UNPACK,3)
, bytes2word(PUSH_HEAP,HEAP_ARG,1,HEAP_CVAL_I3)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,3)
, bytes2word(PUSH_P1,0,ZAP_ARG_I1,EVAL)
, bytes2word(PUSH_ARG_I2,EVAL,NEEDHEAP_I32,LT_W)
, bytes2word(JUMPFALSE,10,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_ARG,2)
,	/* v10061: (byte 3) */
  bytes2word(HEAP_P1,4,RETURN,PUSH_CVAL_P1)
, bytes2word(5,EVAL,NEEDHEAP_I32,JUMPFALSE)
, bytes2word(16,0,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,2,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_OFF_N1)
,	/* v10063: (byte 4) */
  bytes2word(4,HEAP_P1,5,RETURN)
, bytes2word(POP_P1,5,JUMP,100)
,	/* v10065: (byte 1) */
  bytes2word(0,UNPACK,4,PUSH_HEAP)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I3,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I3,HEAP_P1)
, bytes2word(0,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_P1,5,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_I2,HEAP_OFF_N1,5)
, bytes2word(PUSH_P1,2,ZAP_ARG_I1,EVAL)
, bytes2word(PUSH_ARG_I2,EVAL,NEEDHEAP_I32,LT_W)
, bytes2word(JUMPFALSE,10,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_ARG,2)
,	/* v10066: (byte 3) */
  bytes2word(HEAP_P1,6,RETURN,PUSH_P1)
, bytes2word(0,EVAL,NEEDHEAP_I32,PUSH_ARG_I2)
, bytes2word(LT_W,JUMPFALSE,15,0)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,2)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_OFF_N1,4,HEAP_P1,7)
,	/* v10068: (byte 1) */
  bytes2word(RETURN,PUSH_CVAL_P1,5,EVAL)
, bytes2word(NEEDHEAP_I32,JUMPFALSE,16,0)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,2)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_OFF_N1,4,HEAP_P1)
,	/* v10070: (byte 2) */
  bytes2word(8,RETURN,POP_P1,8)
,	/* v10057: (byte 3) */
  bytes2word(JUMP,2,0,HEAP_CVAL_P1)
, bytes2word(8,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v10073: (byte 0) */
  HW(7,3)
, 0
,	/* F0_Data_46Sequence_46lookupNode: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46lookupNode),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_LAMBDA9596))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10075)
,	/* FN_LAMBDA9596: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10074)
,	/* CT_v10075: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9596: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9596))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10092)
,	/* FN_Data_46Sequence_46lookupTree: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10079: (byte 4) */
  bytes2word(TOP(13),BOT(13),TOP(22),BOT(22))
, bytes2word(POP_I1,HEAP_CVAL_I3,PUSH_HEAP,HEAP_CVAL_I4)
,	/* v10080: (byte 3) */
  bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,UNPACK)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10081: (byte 4) */
  bytes2word(HEAP_ARG,2,HEAP_I1,RETURN)
, bytes2word(UNPACK,4,PUSH_HEAP,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I5,HEAP_I1)
, bytes2word(HEAP_P1,3,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_P1,7,HEAP_P1,4)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_I1)
, bytes2word(HEAP_OFF_N1,5,PUSH_I1,EVAL)
, bytes2word(PUSH_ARG_I2,EVAL,NEEDHEAP_I32,LT_W)
, bytes2word(JUMPFALSE,11,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,9,HEAP_ARG_ARG,1)
,	/* v10082: (byte 4) */
  bytes2word(2,HEAP_P1,5,RETURN_EVAL)
, bytes2word(PUSH_P1,0,EVAL,NEEDHEAP_I32)
, bytes2word(PUSH_ARG_I2,LT_W,JUMPFALSE,28)
, bytes2word(0,HEAP_CVAL_P1,10,HEAP_ARG)
, bytes2word(2,HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(11,HEAP_CVAL_P1,7,HEAP_OFF_N1)
, bytes2word(5,HEAP_P1,6,EVAL)
, bytes2word(NEEDHEAP_I32,UNPACK,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,12,HEAP_ARG,1)
,	/* v10084: (byte 3) */
  bytes2word(HEAP_I1,HEAP_I2,RETURN_EVAL,PUSH_CVAL_P1)
, bytes2word(13,EVAL,NEEDHEAP_I32,JUMPFALSE)
, bytes2word(18,0,HEAP_CVAL_P1,10)
, bytes2word(HEAP_ARG,2,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,5,HEAP_P1)
,	/* v10088: (byte 2) */
  bytes2word(7,RETURN_EVAL,POP_P1,7)
,	/* v10076: (byte 3) */
  bytes2word(JUMP,2,0,HEAP_CVAL_P1)
, bytes2word(14,PUSH_HEAP,HEAP_CVAL_P1,15)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v10092: (byte 0) */
  HW(13,3)
, 0
,	/* F0_Data_46Sequence_46lookupTree: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46lookupTree),3)
, VAPTAG(useLabel(FN_LAMBDA9597))
, VAPTAG(useLabel(FN_Prelude_46error))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit_46size))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46lookupDigit))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_45))
, VAPTAG(useLabel(FN_Data_46Sequence_46lookupTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46lookupNode))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_LAMBDA9598))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10094)
,	/* FN_LAMBDA9598: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10093)
,	/* CT_v10094: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9598: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9598))
, bytes2word(0,0,0,0)
, useLabel(CT_v10096)
,	/* FN_LAMBDA9597: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10095)
,	/* CT_v10096: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9597: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9597))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10104)
,};
Node FN_Data_46Sequence_46index[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_INT_P1,0)
, bytes2word(HEAP_ARG,2,HEAP_CVAL_I4,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,2,HEAP_OFF_N1,5)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_OFF_N1)
, bytes2word(10,HEAP_OFF_N1,5,EVAL)
, bytes2word(NEEDHEAP_I32,JUMPFALSE,16,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG_ARG,2,1,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,EVAL,UNPACK,2)
,	/* v10097: (byte 2) */
  bytes2word(PUSH_I1,RETURN_EVAL,PUSH_CVAL_P1,9)
, bytes2word(ZAP_ARG_I1,ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(JUMPFALSE,10,0,HEAP_CVAL_P1)
, bytes2word(10,PUSH_HEAP,HEAP_CVAL_P1,11)
,	/* v10101: (byte 3) */
  bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,HEAP_CVAL_P1)
, bytes2word(12,PUSH_HEAP,HEAP_CVAL_P1,13)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10104: (byte 0) */
  HW(11,2)
, 0
,};
Node F0_Data_46Sequence_46index[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46index),2)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46_60_61))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46_60))
, VAPTAG(useLabel(FN_Prelude_46_38_38))
, VAPTAG(useLabel(FN_Data_46Sequence_46lookupTree))
, useLabel(CF_Prelude_46otherwise)
, VAPTAG(useLabel(FN_LAMBDA9599))
, VAPTAG(useLabel(FN_Prelude_46error))
, VAPTAG(useLabel(FN_LAMBDA9600))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10106)
,	/* FN_LAMBDA9600: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10105)
,	/* CT_v10106: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9600: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9600))
, bytes2word(0,0,0,0)
, useLabel(CT_v10108)
,	/* FN_LAMBDA9599: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10107)
,	/* CT_v10108: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9599: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9599))
, bytes2word(1,0,0,1)
, useLabel(CT_v10113)
,};
Node FN_Data_46Sequence_46viewr[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,ZAP_ARG_I1,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,2,NOP)
,	/* v10110: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(9),BOT(9))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10111: (byte 1) */
  bytes2word(RETURN,UNPACK,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_I1,HEAP_I2)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTR(1,2,0)
, CONSTR(0,0,0)
,	/* CT_v10113: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Data_46Sequence_46viewr[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46viewr),1)
, VAPTAG(useLabel(FN_Data_46Sequence_46viewRTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10118)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46traverse[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10115: (byte 2) */
  bytes2word(TOP(16),BOT(16),POP_I1,PUSH_CVAL_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,EVAL,NEEDHEAP_I32,APPLY)
,	/* v10116: (byte 2) */
  bytes2word(1,RETURN_EVAL,UNPACK,2)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_ARG_ARG)
, bytes2word(1,2,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_OFF_N1)
, bytes2word(8,HEAP_OFF_N1,7,HEAP_OFF_N1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_ARG,2,HEAP_P1,3)
, bytes2word(PUSH_P1,0,PUSH_P1,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_ARG)
, bytes2word(1,ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1)
, bytes2word(6,ZAP_STACK_P1,5,ZAP_STACK_P1)
, bytes2word(4,ZAP_STACK_P1,3,EVAL)
, bytes2word(NEEDHEAP_I32,APPLY,2,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10118: (byte 0) */
  HW(8,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46traverse[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46traverse),3)
, useLabel(C0_Data_46Sequence_46EmptyR)
, VAPTAG(useLabel(FN_Control_46Applicative_46pure))
, VAPTAG(useLabel(FN_Control_46Applicative_46Applicative_46Prelude_46Functor))
, CAPTAG(useLabel(FN_LAMBDA9601),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46traverse))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_36_62))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_42_62))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10119)
,	/* FN_LAMBDA9601: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,2,0)
,	/* CT_v10119: (byte 0) */
  HW(0,2)
, 0
,	/* F0_LAMBDA9601: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9601),2)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10120)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46sequence[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10120: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46sequence[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46sequence),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequence))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10121)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46mapM[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10121: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46mapM[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46mapM),3)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46mapM))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10122)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46sequenceA[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10122: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46sequenceA[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46sequenceA),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequenceA))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10127)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldr1[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10124: (byte 2) */
  bytes2word(TOP(11),BOT(11),POP_I1,HEAP_CVAL_I3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,2)
,	/* v10125: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_I2)
, bytes2word(HEAP_I1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10127: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldr1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldr1),2)
, VAPTAG(useLabel(FN_LAMBDA9602))
, VAPTAG(useLabel(FN_Prelude_46error))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr))
, bytes2word(0,0,0,0)
, useLabel(CT_v10129)
,	/* FN_LAMBDA9602: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10128)
,	/* CT_v10129: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9602: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9602))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10134)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldl[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10131: (byte 2) */
  bytes2word(TOP(7),BOT(7),POP_I1,PUSH_ARG_I2)
,	/* v10132: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG_ARG,1,2)
, bytes2word(HEAP_I1,PUSH_P1,2,PUSH_I1)
, bytes2word(PUSH_ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1,5)
, bytes2word(ZAP_STACK_P1,4,ZAP_STACK_P1,3)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10134: (byte 0) */
  HW(1,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldl[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldl),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10139)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldr[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10136: (byte 2) */
  bytes2word(TOP(7),BOT(7),POP_I1,PUSH_ARG_I2)
,	/* v10137: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_I1,HEAP_ARG)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,6,HEAP_I1)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10139: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldr[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldr),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10140)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldl1[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10140: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldl1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldl1),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldl1))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10141)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldMap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10141: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldMap[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldMap),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldMap))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10142)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46fold[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10142: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46fold[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46fold),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46fold))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10143)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46ViewR_46fmap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_ARG_I2,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10143: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Functor_46Data_46Sequence_46ViewR_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46ViewR_46fmap),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46fmapDefault))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10144)
,};
Node FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewR_46typeOf[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10144: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewR_46typeOf[] = {
  CAPTAG(useLabel(FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewR_46typeOf),2)
, VAPTAG(useLabel(FN_Data_46Typeable_46typeOfDefault))
, useLabel(CF_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewR)
, bytes2word(0,0,0,0)
, useLabel(CT_v10145)
,	/* FN_Data_46Sequence_46viewRTc: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10145: (byte 0) */
  HW(2,0)
, 0
,	/* CF_Data_46Sequence_46viewRTc: (byte 0) */
  VAPTAG(useLabel(FN_Data_46Sequence_46viewRTc))
, VAPTAG(useLabel(FN_LAMBDA9603))
, VAPTAG(useLabel(FN_Data_46Typeable_46mkTyCon))
, bytes2word(0,0,0,0)
, useLabel(CT_v10147)
,	/* FN_LAMBDA9603: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10146)
,	/* CT_v10147: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9603: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9603))
, bytes2word(1,0,0,1)
, useLabel(CT_v10148)
,};
Node FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewR_46typeOf1[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,HEAP_CVAL_N1,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,0,0)
,	/* CT_v10148: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewR_46typeOf1[] = {
  CAPTAG(useLabel(FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewR_46typeOf1),1)
, VAPTAG(useLabel(FN_Data_46Typeable_46mkTyConApp))
, useLabel(CF_Data_46Sequence_46viewRTc)
, bytes2word(1,0,0,1)
, useLabel(CT_v10153)
,};
Node FN_Data_46Sequence_46viewl[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,ZAP_ARG_I1,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,2,NOP)
,	/* v10150: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(9),BOT(9))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10151: (byte 1) */
  bytes2word(RETURN,UNPACK,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,2,HEAP_I1,HEAP_I2)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTR(1,2,0)
, CONSTR(0,0,0)
,	/* CT_v10153: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Data_46Sequence_46viewl[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46viewl),1)
, VAPTAG(useLabel(FN_Data_46Sequence_46viewLTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10158)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46traverse[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10155: (byte 2) */
  bytes2word(TOP(16),BOT(16),POP_I1,PUSH_CVAL_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,EVAL,NEEDHEAP_I32,APPLY)
,	/* v10156: (byte 2) */
  bytes2word(1,RETURN_EVAL,UNPACK,2)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(2,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_OFF_N1,7)
, bytes2word(HEAP_OFF_N1,6,HEAP_OFF_N1,6)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_ARG_ARG)
, bytes2word(1,2,HEAP_P1,3)
, bytes2word(PUSH_P1,0,PUSH_P1,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_ARG)
, bytes2word(1,ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1)
, bytes2word(6,ZAP_STACK_P1,5,ZAP_STACK_P1)
, bytes2word(4,ZAP_STACK_P1,3,EVAL)
, bytes2word(NEEDHEAP_I32,APPLY,2,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10158: (byte 0) */
  HW(8,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46traverse[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46traverse),3)
, useLabel(C0_Data_46Sequence_46EmptyL)
, VAPTAG(useLabel(FN_Control_46Applicative_46pure))
, VAPTAG(useLabel(FN_Control_46Applicative_46Applicative_46Prelude_46Functor))
, CAPTAG(useLabel(FN_LAMBDA9604),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_36_62))
, VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46traverse))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_42_62))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10159)
,	/* FN_LAMBDA9604: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,2,0)
,	/* CT_v10159: (byte 0) */
  HW(0,2)
, 0
,	/* F0_LAMBDA9604: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9604),2)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10160)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46sequence[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10160: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46sequence[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46sequence),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequence))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10161)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46mapM[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10161: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46mapM[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46mapM),3)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46mapM))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10162)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46sequenceA[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10162: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46sequenceA[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46sequenceA),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequenceA))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10167)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldl1[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10164: (byte 2) */
  bytes2word(TOP(11),BOT(11),POP_I1,HEAP_CVAL_I3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,2)
,	/* v10165: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_I1)
, bytes2word(HEAP_I2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10167: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldl1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldl1),2)
, VAPTAG(useLabel(FN_LAMBDA9605))
, VAPTAG(useLabel(FN_Prelude_46error))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl))
, bytes2word(0,0,0,0)
, useLabel(CT_v10169)
,	/* FN_LAMBDA9605: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10168)
,	/* CT_v10169: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9605: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9605))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10174)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldl[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10171: (byte 2) */
  bytes2word(TOP(7),BOT(7),POP_I1,PUSH_ARG_I2)
,	/* v10172: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,6,HEAP_I2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10174: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldl[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldl),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10179)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldr[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10176: (byte 2) */
  bytes2word(TOP(7),BOT(7),POP_I1,PUSH_ARG_I2)
,	/* v10177: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG_ARG,1,2)
, bytes2word(HEAP_I2,PUSH_P1,0,PUSH_P1)
, bytes2word(2,PUSH_ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1)
, bytes2word(5,ZAP_STACK_P1,4,ZAP_STACK_P1)
, bytes2word(3,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10179: (byte 0) */
  HW(1,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldr[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldr),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10180)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldr1[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10180: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldr1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldr1),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldr1))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10181)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldMap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10181: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldMap[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldMap),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldMap))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10182)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46fold[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10182: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46fold[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46fold),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46fold))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10183)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46ViewL_46fmap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_ARG_I2,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10183: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Functor_46Data_46Sequence_46ViewL_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46ViewL_46fmap),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46fmapDefault))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10184)
,};
Node FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewL_46typeOf[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10184: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewL_46typeOf[] = {
  CAPTAG(useLabel(FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewL_46typeOf),2)
, VAPTAG(useLabel(FN_Data_46Typeable_46typeOfDefault))
, useLabel(CF_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewL)
, bytes2word(0,0,0,0)
, useLabel(CT_v10185)
,	/* FN_Data_46Sequence_46viewLTc: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10185: (byte 0) */
  HW(2,0)
, 0
,	/* CF_Data_46Sequence_46viewLTc: (byte 0) */
  VAPTAG(useLabel(FN_Data_46Sequence_46viewLTc))
, VAPTAG(useLabel(FN_LAMBDA9606))
, VAPTAG(useLabel(FN_Data_46Typeable_46mkTyCon))
, bytes2word(0,0,0,0)
, useLabel(CT_v10187)
,	/* FN_LAMBDA9606: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10186)
,	/* CT_v10187: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9606: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9606))
, bytes2word(1,0,0,1)
, useLabel(CT_v10188)
,};
Node FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewL_46typeOf1[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,HEAP_CVAL_N1,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,0,0)
,	/* CT_v10188: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewL_46typeOf1[] = {
  CAPTAG(useLabel(FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewL_46typeOf1),1)
, VAPTAG(useLabel(FN_Data_46Typeable_46mkTyConApp))
, useLabel(CF_Data_46Sequence_46viewLTc)
, bytes2word(1,0,0,1)
, useLabel(CT_v10189)
,};
Node FN_Data_46Sequence_46length[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10189: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Data_46Sequence_46length[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46length),1)
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, bytes2word(1,0,0,1)
, useLabel(CT_v10195)
,};
Node FN_Data_46Sequence_46null[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(10),BOT(10))
,	/* v10194: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10193: (byte 4) */
  bytes2word(POP_I1,JUMP,7,0)
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10190: (byte 1) */
  bytes2word(RETURN,PUSH_HEAP,HEAP_CVAL_N1,2)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v10195: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_Data_46Sequence_46null[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46null),1)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10196)
,	/* FN_Data_46Sequence_46node2: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I5,HEAP_OFF_N1,9)
, bytes2word(HEAP_OFF_N1,5,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_OFF_N1,4,HEAP_ARG_ARG)
, bytes2word(2,3,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,3,0)
,	/* CT_v10196: (byte 0) */
  HW(3,3)
, 0
,	/* F0_Data_46Sequence_46node2: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46node2),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v10227)
,	/* FN_Data_46Sequence_46appendTree2: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(10),BOT(10))
,	/* v10221: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10200: (byte 4) */
  bytes2word(POP_I1,JUMP,16,0)
, bytes2word(POP_I1,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(3,4,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,2,HEAP_OFF_N1)
,	/* v10197: (byte 2) */
  bytes2word(7,RETURN_EVAL,PUSH_ARG,4)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,3)
, bytes2word(TOP(10),BOT(10),TOP(6),BOT(6))
,	/* v10222: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10204: (byte 2) */
  bytes2word(16,0,POP_I1,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,1,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_OFF_N1)
,	/* v10201: (byte 4) */
  bytes2word(6,HEAP_ARG,3,RETURN_EVAL)
, bytes2word(PUSH_ARG_I1,TABLESWITCH,3,NOP)
, bytes2word(TOP(6),BOT(6),TOP(10),BOT(10))
,	/* v10223: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10208: (byte 2) */
  bytes2word(22,0,UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(2,HEAP_OFF_N1,7,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1,HEAP_OFF_N1)
,	/* v10205: (byte 2) */
  bytes2word(7,RETURN_EVAL,PUSH_ARG,4)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10224: (byte 4) */
  bytes2word(TOP(10),BOT(10),TOP(6),BOT(6))
,	/* v10212: (byte 4) */
  bytes2word(POP_I1,JUMP,22,0)
, bytes2word(UNPACK,1,HEAP_CVAL_I5,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,6,HEAP_ARG)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I5,HEAP_CVAL_I4)
,	/* v10209: (byte 4) */
  bytes2word(HEAP_OFF_N1,6,HEAP_I1,RETURN_EVAL)
, bytes2word(PUSH_ARG_I1,TABLESWITCH,3,NOP)
, bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10225: (byte 2) */
  bytes2word(TOP(10),BOT(10),POP_I1,JUMP)
,	/* v10216: (byte 2) */
  bytes2word(74,0,UNPACK,4)
, bytes2word(PUSH_ARG,4,TABLESWITCH,3)
, bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10226: (byte 2) */
  bytes2word(TOP(10),BOT(10),POP_I1,JUMP)
,	/* v10220: (byte 2) */
  bytes2word(53,0,UNPACK,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_P1,7,HEAP_P1,4)
, bytes2word(HEAP_OFF_N1,4,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,6,HEAP_OFF_N1,4)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,4)
, bytes2word(HEAP_P1,0,HEAP_CVAL_P1,8)
, bytes2word(HEAP_P1,6,HEAP_P1,7)
, bytes2word(HEAP_ARG_ARG,2,3,HEAP_I1)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_OFF_N1,11,HEAP_P1,6)
, bytes2word(HEAP_OFF_N1,10,HEAP_P1,4)
,	/* v10217: (byte 1) */
  bytes2word(RETURN,POP_P1,4,JUMP)
,	/* v10213: (byte 2) */
  bytes2word(2,0,HEAP_CVAL_P1,9)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_OFF_N1)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
,	/* CT_v10227: (byte 0) */
  HW(8,4)
, 0
,	/* F0_Data_46Sequence_46appendTree2: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46appendTree2),4)
, VAPTAG(useLabel(FN_Data_46Sequence_46consTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46snocTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Node_46size))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46addDigits2))
, VAPTAG(useLabel(FN_LAMBDA9607))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10229)
,	/* FN_LAMBDA9607: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10228)
,	/* CT_v10229: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9607: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9607))
, bytes2word(0,0,6,0)
, bytes2word(5,1,4,2)
, bytes2word(3,3,2,4)
, bytes2word(1,5,0,6)
, useLabel(CT_v10260)
,	/* FN_Data_46Sequence_46addDigits2: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(135),BOT(135),TOP(280),BOT(280))
,	/* v10231: (byte 2) */
  bytes2word(TOP(435),BOT(435),UNPACK,1)
, bytes2word(PUSH_ARG,5,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(32),BOT(32),TOP(57),BOT(57))
,	/* v10233: (byte 2) */
  bytes2word(TOP(85),BOT(85),UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(4,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(10,HEAP_OFF_N1,7,HEAP_ARG)
,	/* v10234: (byte 2) */
  bytes2word(6,RETURN_EVAL,UNPACK,2)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I2)
, bytes2word(HEAP_ARG_ARG,3,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,7)
,	/* v10235: (byte 3) */
  bytes2word(HEAP_ARG,6,RETURN_EVAL,UNPACK)
, bytes2word(3,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,3,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_I2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,8)
,	/* v10236: (byte 3) */
  bytes2word(HEAP_ARG,6,RETURN_EVAL,UNPACK)
, bytes2word(4,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,4,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(0,HEAP_I1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,15,HEAP_OFF_N1,11)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,6)
,	/* v10237: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,PUSH_ARG)
, bytes2word(5,EVAL,NEEDHEAP_I32,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(34),BOT(34),TOP(63),BOT(63))
,	/* v10239: (byte 2) */
  bytes2word(TOP(98),BOT(98),UNPACK,1)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,HEAP_ARG,3,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,4,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,11,HEAP_OFF_N1)
,	/* v10240: (byte 4) */
  bytes2word(7,HEAP_ARG,6,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,4,HEAP_P1)
, bytes2word(0,HEAP_I1,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,12)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,6)
,	/* v10241: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,3,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_P1,3)
, bytes2word(HEAP_P1,4,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG,4)
, bytes2word(HEAP_P1,0,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(15,HEAP_OFF_N1,11,HEAP_OFF_N1)
,	/* v10242: (byte 4) */
  bytes2word(8,HEAP_ARG,6,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,4,HEAP_P1)
, bytes2word(5,HEAP_ARG,3,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_ARG,4)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_P1,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,16,HEAP_OFF_N1)
, bytes2word(12,HEAP_OFF_N1,8,HEAP_ARG)
,	/* v10243: (byte 2) */
  bytes2word(6,RETURN_EVAL,UNPACK,3)
, bytes2word(PUSH_ARG,5,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(36),BOT(36),TOP(70),BOT(70))
,	/* v10245: (byte 2) */
  bytes2word(TOP(107),BOT(107),UNPACK,1)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,HEAP_P1,3,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(12,HEAP_OFF_N1,8,HEAP_ARG)
,	/* v10246: (byte 2) */
  bytes2word(6,RETURN_EVAL,UNPACK,2)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I2)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(0,HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(15,HEAP_OFF_N1,11,HEAP_OFF_N1)
,	/* v10247: (byte 4) */
  bytes2word(8,HEAP_ARG,6,RETURN_EVAL)
, bytes2word(UNPACK,3,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,3,HEAP_P1)
, bytes2word(4,HEAP_P1,5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_P1,0,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_I1,HEAP_I2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,16,HEAP_OFF_N1,12)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,6)
,	/* v10248: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(3,4,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,17,HEAP_OFF_N1,13)
, bytes2word(HEAP_OFF_N1,9,HEAP_ARG,6)
,	/* v10249: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,PUSH_ZAP_ARG)
, bytes2word(5,EVAL,NEEDHEAP_I32,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(43),BOT(43),TOP(80),BOT(80))
,	/* v10251: (byte 2) */
  bytes2word(TOP(120),BOT(120),UNPACK,1)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,HEAP_P1,3,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,4,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(4,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,15,HEAP_OFF_N1,11)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,6)
,	/* v10252: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_I2,HEAP_P1)
, bytes2word(3,HEAP_P1,4,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_P1,5)
, bytes2word(HEAP_ARG_ARG,3,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,16,HEAP_OFF_N1)
, bytes2word(12,HEAP_OFF_N1,8,HEAP_ARG)
,	/* v10253: (byte 2) */
  bytes2word(6,RETURN_EVAL,UNPACK,3)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(3,HEAP_P1,4,HEAP_P1)
, bytes2word(5,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,6,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_I2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,17,HEAP_OFF_N1)
, bytes2word(13,HEAP_OFF_N1,9,HEAP_ARG)
,	/* v10254: (byte 2) */
  bytes2word(6,RETURN_EVAL,UNPACK,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(4,HEAP_P1,5,HEAP_P1)
, bytes2word(6,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,7,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(0,HEAP_I1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,20,HEAP_OFF_N1,16)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,9)
, bytes2word(HEAP_ARG,6,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10260: (byte 0) */
  HW(6,6)
, 0
,	/* F0_Data_46Sequence_46addDigits2: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46addDigits2),6)
, VAPTAG(useLabel(FN_Data_46Sequence_46node2))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree2))
, VAPTAG(useLabel(FN_Data_46Sequence_46node3))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree3))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree4))
, bytes2word(5,0,4,1)
, bytes2word(3,2,2,3)
, bytes2word(1,4,0,5)
, useLabel(CT_v10291)
,	/* FN_Data_46Sequence_46appendTree3: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(10),BOT(10))
,	/* v10285: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10264: (byte 4) */
  bytes2word(POP_I1,JUMP,22,0)
, bytes2word(POP_I1,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(4,5,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,3,HEAP_OFF_N1,7)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG)
,	/* v10261: (byte 4) */
  bytes2word(2,HEAP_OFF_N1,7,RETURN_EVAL)
, bytes2word(PUSH_ARG,5,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(10),BOT(10))
,	/* v10286: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10268: (byte 4) */
  bytes2word(POP_I1,JUMP,22,0)
, bytes2word(POP_I1,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(1,2,HEAP_CVAL_I5,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,6,HEAP_ARG,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_OFF_N1)
,	/* v10265: (byte 4) */
  bytes2word(6,HEAP_ARG,4,RETURN_EVAL)
, bytes2word(PUSH_ARG_I1,TABLESWITCH,3,NOP)
, bytes2word(TOP(6),BOT(6),TOP(10),BOT(10))
,	/* v10287: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10272: (byte 2) */
  bytes2word(28,0,UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG,4)
, bytes2word(5,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(3,HEAP_OFF_N1,7,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
,	/* v10269: (byte 4) */
  bytes2word(HEAP_I1,HEAP_OFF_N1,7,RETURN_EVAL)
, bytes2word(PUSH_ARG,5,TABLESWITCH,3)
, bytes2word(TOP(6),BOT(6),TOP(10),BOT(10))
,	/* v10288: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10276: (byte 2) */
  bytes2word(28,0,UNPACK,1)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(6,HEAP_ARG,3,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,6,HEAP_ARG)
, bytes2word(4,PUSH_HEAP,HEAP_CVAL_I5,HEAP_CVAL_I4)
,	/* v10273: (byte 4) */
  bytes2word(HEAP_OFF_N1,6,HEAP_I1,RETURN_EVAL)
, bytes2word(PUSH_ARG_I1,TABLESWITCH,3,NOP)
, bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10289: (byte 2) */
  bytes2word(TOP(10),BOT(10),POP_I1,JUMP)
,	/* v10280: (byte 2) */
  bytes2word(86,0,UNPACK,4)
, bytes2word(PUSH_ARG,5,TABLESWITCH,3)
, bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10290: (byte 2) */
  bytes2word(TOP(10),BOT(10),POP_I1,JUMP)
,	/* v10284: (byte 2) */
  bytes2word(65,0,UNPACK,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_P1,7,HEAP_P1,4)
, bytes2word(HEAP_OFF_N1,4,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,6,HEAP_OFF_N1,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,4)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,6)
, bytes2word(HEAP_OFF_N1,4,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,4,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,8,HEAP_P1,6)
, bytes2word(HEAP_P1,7,HEAP_ARG_ARG,2)
, bytes2word(3,HEAP_ARG,4,HEAP_I1)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_OFF_N1,12,HEAP_P1,6)
, bytes2word(HEAP_OFF_N1,11,HEAP_P1,4)
,	/* v10281: (byte 1) */
  bytes2word(RETURN,POP_P1,4,JUMP)
,	/* v10277: (byte 2) */
  bytes2word(2,0,HEAP_CVAL_P1,9)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_OFF_N1)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
,	/* CT_v10291: (byte 0) */
  HW(8,5)
, 0
,	/* F0_Data_46Sequence_46appendTree3: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46appendTree3),5)
, VAPTAG(useLabel(FN_Data_46Sequence_46consTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46snocTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Node_46size))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46addDigits3))
, VAPTAG(useLabel(FN_LAMBDA9608))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10293)
,	/* FN_LAMBDA9608: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10292)
,	/* CT_v10293: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9608: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9608))
, bytes2word(7,0,6,1)
, bytes2word(5,2,4,3)
, bytes2word(3,4,2,5)
, bytes2word(1,6,0,7)
, useLabel(CT_v10324)
,	/* FN_Data_46Sequence_46addDigits3: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(145),BOT(145),TOP(294),BOT(294))
,	/* v10295: (byte 2) */
  bytes2word(TOP(458),BOT(458),UNPACK,1)
, bytes2word(PUSH_ARG,6,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(34),BOT(34),TOP(61),BOT(61))
,	/* v10297: (byte 2) */
  bytes2word(TOP(94),BOT(94),UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1,HEAP_ARG_ARG)
, bytes2word(3,4,HEAP_CVAL_I5,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,5,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,6,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,11,HEAP_OFF_N1)
,	/* v10298: (byte 4) */
  bytes2word(7,HEAP_ARG,7,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_ARG_ARG,3,4)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG,5)
, bytes2word(HEAP_P1,0,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,8)
,	/* v10299: (byte 3) */
  bytes2word(HEAP_ARG,7,RETURN_EVAL,UNPACK)
, bytes2word(3,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(3,HEAP_ARG_ARG,3,4)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG,5)
, bytes2word(HEAP_P1,0,HEAP_CVAL_I5,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(15,HEAP_OFF_N1,11,HEAP_OFF_N1)
,	/* v10300: (byte 4) */
  bytes2word(8,HEAP_ARG,7,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,4,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(5,HEAP_P1,0,HEAP_I1)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_I2,HEAP_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,16)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,8)
,	/* v10301: (byte 3) */
  bytes2word(HEAP_ARG,7,RETURN_EVAL,UNPACK)
, bytes2word(2,PUSH_ARG,6,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,4,NOP)
, bytes2word(TOP(8),BOT(8),TOP(35),BOT(35))
,	/* v10303: (byte 4) */
  bytes2word(TOP(68),BOT(68),TOP(103),BOT(103))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG,4)
, bytes2word(5,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,8)
,	/* v10304: (byte 3) */
  bytes2word(HEAP_ARG,7,RETURN_EVAL,UNPACK)
, bytes2word(2,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I2)
, bytes2word(HEAP_P1,3,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG_ARG,4)
, bytes2word(5,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(0,HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(15,HEAP_OFF_N1,11,HEAP_OFF_N1)
,	/* v10305: (byte 4) */
  bytes2word(8,HEAP_ARG,7,RETURN_EVAL)
, bytes2word(UNPACK,3,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,4,5,HEAP_P1)
, bytes2word(0,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,16)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,8)
,	/* v10306: (byte 3) */
  bytes2word(HEAP_ARG,7,RETURN_EVAL,UNPACK)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(4,HEAP_P1,5,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(4,5,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1,HEAP_I2)
, bytes2word(HEAP_P1,3,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(17,HEAP_OFF_N1,13,HEAP_OFF_N1)
,	/* v10307: (byte 4) */
  bytes2word(9,HEAP_ARG,7,RETURN_EVAL)
, bytes2word(UNPACK,3,PUSH_ARG,6)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,4)
, bytes2word(TOP(8),BOT(8),TOP(41),BOT(41))
,	/* v10309: (byte 4) */
  bytes2word(TOP(76),BOT(76),TOP(113),BOT(113))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(5,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,15,HEAP_OFF_N1,11)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,7)
,	/* v10310: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_P1,4,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,3,4,HEAP_ARG)
, bytes2word(5,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(0,HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(16,HEAP_OFF_N1,12,HEAP_OFF_N1)
,	/* v10311: (byte 4) */
  bytes2word(8,HEAP_ARG,7,RETURN_EVAL)
, bytes2word(UNPACK,3,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,3,4,HEAP_ARG)
, bytes2word(5,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(0,HEAP_I1,HEAP_I2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,17,HEAP_OFF_N1,13)
, bytes2word(HEAP_OFF_N1,9,HEAP_ARG,7)
,	/* v10312: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,4,HEAP_P1)
, bytes2word(5,HEAP_P1,6,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,3,4)
, bytes2word(HEAP_ARG,5,HEAP_CVAL_I5,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_P1,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,20,HEAP_OFF_N1)
, bytes2word(16,HEAP_OFF_N1,12,HEAP_OFF_N1)
,	/* v10313: (byte 4) */
  bytes2word(9,HEAP_ARG,7,RETURN_EVAL)
, bytes2word(UNPACK,4,PUSH_ZAP_ARG,6)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,4)
, bytes2word(TOP(8),BOT(8),TOP(43),BOT(43))
,	/* v10315: (byte 4) */
  bytes2word(TOP(80),BOT(80),TOP(123),BOT(123))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,4)
, bytes2word(HEAP_ARG_ARG,3,4,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,5,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,16)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,8)
,	/* v10316: (byte 3) */
  bytes2word(HEAP_ARG,7,RETURN_EVAL,UNPACK)
, bytes2word(2,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I2)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,5)
, bytes2word(HEAP_ARG_ARG,3,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,5,HEAP_P1)
, bytes2word(0,HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(17,HEAP_OFF_N1,13,HEAP_OFF_N1)
,	/* v10317: (byte 4) */
  bytes2word(9,HEAP_ARG,7,RETURN_EVAL)
, bytes2word(UNPACK,3,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,6,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(5,HEAP_P1,0,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_I1,HEAP_I2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,20,HEAP_OFF_N1,16)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,9)
,	/* v10318: (byte 3) */
  bytes2word(HEAP_ARG,7,RETURN_EVAL,UNPACK)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(4,HEAP_P1,5,HEAP_P1)
, bytes2word(6,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(7,HEAP_ARG_ARG,3,4)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG,5)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_P1,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,21,HEAP_OFF_N1)
, bytes2word(17,HEAP_OFF_N1,13,HEAP_OFF_N1)
, bytes2word(9,HEAP_ARG,7,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10324: (byte 0) */
  HW(6,7)
, 0
,	/* F0_Data_46Sequence_46addDigits3: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46addDigits3),7)
, VAPTAG(useLabel(FN_Data_46Sequence_46node3))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46node2))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree2))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree3))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree4))
, bytes2word(0,0,6,0)
, bytes2word(5,1,4,2)
, bytes2word(3,3,2,4)
, bytes2word(1,5,0,6)
, useLabel(CT_v10355)
,	/* FN_Data_46Sequence_46appendTree4: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(10),BOT(10))
,	/* v10349: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10328: (byte 4) */
  bytes2word(POP_I1,JUMP,28,0)
, bytes2word(POP_I1,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(5,6,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,4,HEAP_OFF_N1,7)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG,3)
, bytes2word(HEAP_OFF_N1,7,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,2,HEAP_OFF_N1)
,	/* v10325: (byte 2) */
  bytes2word(7,RETURN_EVAL,PUSH_ARG,6)
, bytes2word(EVAL,NEEDHEAP_P1,37,TABLESWITCH)
, bytes2word(3,NOP,TOP(10),BOT(10))
,	/* v10350: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10332: (byte 4) */
  bytes2word(POP_I1,JUMP,28,0)
, bytes2word(POP_I1,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(1,2,HEAP_CVAL_I5,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,6,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_OFF_N1,6)
, bytes2word(HEAP_ARG,4,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,6,HEAP_ARG)
,	/* v10329: (byte 2) */
  bytes2word(5,RETURN_EVAL,PUSH_ARG_I1,TABLESWITCH)
, bytes2word(3,NOP,TOP(6),BOT(6))
,	/* v10351: (byte 4) */
  bytes2word(TOP(10),BOT(10),TOP(6),BOT(6))
,	/* v10336: (byte 4) */
  bytes2word(POP_I1,JUMP,34,0)
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,5,6,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,4,HEAP_OFF_N1)
, bytes2word(7,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(3,HEAP_OFF_N1,7,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,2,HEAP_OFF_N1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
,	/* v10333: (byte 4) */
  bytes2word(HEAP_I1,HEAP_OFF_N1,7,RETURN_EVAL)
, bytes2word(PUSH_ARG,6,TABLESWITCH,3)
, bytes2word(TOP(6),BOT(6),TOP(10),BOT(10))
,	/* v10352: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10340: (byte 2) */
  bytes2word(34,0,UNPACK,1)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(6,HEAP_ARG,3,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,6,HEAP_ARG)
, bytes2word(4,HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(6,HEAP_ARG,5,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_OFF_N1,6)
,	/* v10337: (byte 2) */
  bytes2word(HEAP_I1,RETURN_EVAL,PUSH_ARG_I1,TABLESWITCH)
, bytes2word(3,NOP,TOP(6),BOT(6))
,	/* v10353: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(10),BOT(10))
,	/* v10344: (byte 4) */
  bytes2word(POP_I1,JUMP,97,0)
, bytes2word(UNPACK,4,PUSH_ARG,6)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10354: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(10),BOT(10))
,	/* v10348: (byte 4) */
  bytes2word(POP_I1,JUMP,76,0)
, bytes2word(UNPACK,4,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,2,HEAP_CVAL_P1,7)
, bytes2word(HEAP_P1,4,HEAP_OFF_N1,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,6)
, bytes2word(HEAP_OFF_N1,4,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,4,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,6,HEAP_OFF_N1,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,5)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,6)
, bytes2word(HEAP_OFF_N1,4,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,4,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,8,HEAP_P1,6)
, bytes2word(HEAP_P1,7,HEAP_ARG_ARG,2)
, bytes2word(3,HEAP_ARG_ARG,4,5)
, bytes2word(HEAP_I1,HEAP_I2,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_OFF_N1,13,HEAP_P1)
, bytes2word(6,HEAP_OFF_N1,12,HEAP_P1)
,	/* v10345: (byte 2) */
  bytes2word(4,RETURN,POP_P1,4)
,	/* v10341: (byte 3) */
  bytes2word(JUMP,2,0,HEAP_CVAL_P1)
, bytes2word(9,PUSH_HEAP,HEAP_CVAL_P1,10)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
,	/* CT_v10355: (byte 0) */
  HW(8,6)
, 0
,	/* F0_Data_46Sequence_46appendTree4: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46appendTree4),6)
, VAPTAG(useLabel(FN_Data_46Sequence_46consTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46snocTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Node_46size))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46addDigits4))
, VAPTAG(useLabel(FN_LAMBDA9609))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10357)
,	/* FN_LAMBDA9609: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10356)
,	/* CT_v10357: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9609: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9609))
, bytes2word(0,0,8,0)
, bytes2word(7,1,6,2)
, bytes2word(5,3,4,4)
, bytes2word(3,5,2,6)
, bytes2word(1,7,0,8)
, useLabel(CT_v10388)
,	/* FN_Data_46Sequence_46addDigits4: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(155),BOT(155),TOP(325),BOT(325))
,	/* v10359: (byte 2) */
  bytes2word(TOP(506),BOT(506),UNPACK,1)
, bytes2word(PUSH_ARG,7,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(34),BOT(34),TOP(68),BOT(68))
,	/* v10361: (byte 2) */
  bytes2word(TOP(103),BOT(103),UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1,HEAP_ARG_ARG)
, bytes2word(3,4,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,5,6,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,12,HEAP_OFF_N1)
,	/* v10362: (byte 4) */
  bytes2word(8,HEAP_ARG,8,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_ARG_ARG,3,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(5,6,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,15,HEAP_OFF_N1)
, bytes2word(11,HEAP_OFF_N1,8,HEAP_ARG)
,	/* v10363: (byte 2) */
  bytes2word(8,RETURN_EVAL,UNPACK,3)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,3)
, bytes2word(HEAP_ARG_ARG,3,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,5,6)
, bytes2word(HEAP_P1,0,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_I1,HEAP_I2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,16,HEAP_OFF_N1,12)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,8)
,	/* v10364: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,4,HEAP_ARG_ARG)
, bytes2word(3,4,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,5,6,HEAP_P1)
, bytes2word(0,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,17,HEAP_OFF_N1,13)
, bytes2word(HEAP_OFF_N1,9,HEAP_ARG,8)
,	/* v10365: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,PUSH_ARG)
, bytes2word(7,EVAL,NEEDHEAP_I32,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(43),BOT(43),TOP(79),BOT(79))
,	/* v10367: (byte 2) */
  bytes2word(TOP(116),BOT(116),UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1,HEAP_I2)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,4,5)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(6,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,15,HEAP_OFF_N1,11)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,8)
,	/* v10368: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,4,5,HEAP_ARG)
, bytes2word(6,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,16,HEAP_OFF_N1,12)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,8)
,	/* v10369: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,3,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,3,HEAP_P1)
, bytes2word(4,HEAP_ARG,3,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,4,5)
, bytes2word(HEAP_ARG,6,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_I2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,17,HEAP_OFF_N1)
, bytes2word(13,HEAP_OFF_N1,9,HEAP_ARG)
,	/* v10370: (byte 2) */
  bytes2word(8,RETURN_EVAL,UNPACK,4)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG,4)
, bytes2word(5,HEAP_ARG,6,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_P1,0)
, bytes2word(HEAP_I1,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,20,HEAP_OFF_N1,16)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,9)
,	/* v10371: (byte 3) */
  bytes2word(HEAP_ARG,8,RETURN_EVAL,UNPACK)
, bytes2word(3,PUSH_ARG,7,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,4,NOP)
, bytes2word(TOP(8),BOT(8),TOP(44),BOT(44))
,	/* v10373: (byte 4) */
  bytes2word(TOP(81),BOT(81),TOP(126),BOT(126))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_ARG,5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_ARG,6)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(16,HEAP_OFF_N1,12,HEAP_OFF_N1)
,	/* v10374: (byte 4) */
  bytes2word(8,HEAP_ARG,8,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,HEAP_P1)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(3,4,HEAP_ARG,5)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG,6)
, bytes2word(HEAP_P1,0,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,17,HEAP_OFF_N1,13)
, bytes2word(HEAP_OFF_N1,9,HEAP_ARG,8)
,	/* v10375: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,3,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,3,HEAP_P1)
, bytes2word(4,HEAP_P1,5,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,3,4)
, bytes2word(HEAP_ARG,5,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,6,HEAP_P1)
, bytes2word(0,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(20,HEAP_OFF_N1,16,HEAP_OFF_N1)
, bytes2word(12,HEAP_OFF_N1,9,HEAP_ARG)
,	/* v10376: (byte 2) */
  bytes2word(8,RETURN_EVAL,UNPACK,4)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_ARG,5,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,6,HEAP_P1)
, bytes2word(0,HEAP_I1,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_P1,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,21,HEAP_OFF_N1)
, bytes2word(17,HEAP_OFF_N1,13,HEAP_OFF_N1)
,	/* v10377: (byte 4) */
  bytes2word(9,HEAP_ARG,8,RETURN_EVAL)
, bytes2word(UNPACK,4,PUSH_ZAP_ARG,7)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,4)
, bytes2word(TOP(8),BOT(8),TOP(44),BOT(44))
,	/* v10379: (byte 4) */
  bytes2word(TOP(88),BOT(88),TOP(133),BOT(133))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,4)
, bytes2word(HEAP_ARG_ARG,3,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,5,6)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(17,HEAP_OFF_N1,13,HEAP_OFF_N1)
,	/* v10380: (byte 4) */
  bytes2word(9,HEAP_ARG,8,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,HEAP_P1)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(5,HEAP_ARG_ARG,3,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(5,6,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,20,HEAP_OFF_N1)
, bytes2word(16,HEAP_OFF_N1,12,HEAP_OFF_N1)
,	/* v10381: (byte 4) */
  bytes2word(9,HEAP_ARG,8,RETURN_EVAL)
, bytes2word(UNPACK,3,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,6,HEAP_ARG_ARG,3)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG)
, bytes2word(5,6,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,21)
, bytes2word(HEAP_OFF_N1,17,HEAP_OFF_N1,13)
, bytes2word(HEAP_OFF_N1,9,HEAP_ARG,8)
,	/* v10382: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,4,HEAP_P1)
, bytes2word(5,HEAP_P1,6,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,7,HEAP_ARG_ARG)
, bytes2word(3,4,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,5,6,HEAP_P1)
, bytes2word(0,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,22,HEAP_OFF_N1,18)
, bytes2word(HEAP_OFF_N1,14,HEAP_OFF_N1,10)
, bytes2word(HEAP_ARG,8,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10388: (byte 0) */
  HW(6,8)
, 0
,	/* F0_Data_46Sequence_46addDigits4: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46addDigits4),8)
, VAPTAG(useLabel(FN_Data_46Sequence_46node3))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree2))
, VAPTAG(useLabel(FN_Data_46Sequence_46node2))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree3))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree4))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10419)
,	/* FN_Data_46Sequence_46appendTree1: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(10),BOT(10))
,	/* v10413: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10392: (byte 4) */
  bytes2word(POP_I1,JUMP,9,0)
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
,	/* v10389: (byte 3) */
  bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,3)
, bytes2word(TOP(10),BOT(10),TOP(6),BOT(6))
,	/* v10414: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10396: (byte 2) */
  bytes2word(9,0,POP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG_ARG_RET_EVAL,1)
,	/* v10393: (byte 1) */
  bytes2word(2,PUSH_ARG_I1,TABLESWITCH,3)
, bytes2word(TOP(6),BOT(6),TOP(10),BOT(10))
,	/* v10415: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10400: (byte 2) */
  bytes2word(16,0,UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG_ARG,2)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
,	/* v10397: (byte 4) */
  bytes2word(HEAP_I1,HEAP_OFF_N1,7,RETURN_EVAL)
, bytes2word(PUSH_ARG_I3,TABLESWITCH,3,NOP)
, bytes2word(TOP(6),BOT(6),TOP(10),BOT(10))
,	/* v10416: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10404: (byte 2) */
  bytes2word(16,0,UNPACK,1)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_I4,HEAP_ARG_ARG,1)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_I5,HEAP_CVAL_I4)
,	/* v10401: (byte 4) */
  bytes2word(HEAP_OFF_N1,6,HEAP_I1,RETURN_EVAL)
, bytes2word(PUSH_ARG_I1,TABLESWITCH,3,NOP)
, bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10417: (byte 2) */
  bytes2word(TOP(10),BOT(10),POP_I1,JUMP)
,	/* v10408: (byte 2) */
  bytes2word(63,0,UNPACK,4)
, bytes2word(PUSH_ARG_I3,TABLESWITCH,3,NOP)
, bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10418: (byte 2) */
  bytes2word(TOP(10),BOT(10),POP_I1,JUMP)
,	/* v10412: (byte 2) */
  bytes2word(42,0,UNPACK,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_P1,7,HEAP_P1,4)
, bytes2word(HEAP_OFF_N1,4,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,4,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,8,HEAP_P1,6)
, bytes2word(HEAP_P1,7,HEAP_ARG,2)
, bytes2word(HEAP_I1,HEAP_I2,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_OFF_N1,10,HEAP_P1)
, bytes2word(6,HEAP_OFF_N1,9,HEAP_P1)
,	/* v10409: (byte 2) */
  bytes2word(4,RETURN,POP_P1,4)
,	/* v10405: (byte 3) */
  bytes2word(JUMP,2,0,HEAP_CVAL_P1)
, bytes2word(9,PUSH_HEAP,HEAP_CVAL_P1,10)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
,	/* CT_v10419: (byte 0) */
  HW(8,3)
, 0
,	/* F0_Data_46Sequence_46appendTree1: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46appendTree1),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46consTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46snocTree))
, VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Node_46size))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46addDigits1))
, VAPTAG(useLabel(FN_LAMBDA9610))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10421)
,	/* FN_LAMBDA9610: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10420)
,	/* CT_v10421: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9610: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9610))
, bytes2word(5,0,4,1)
, bytes2word(3,2,2,3)
, bytes2word(1,4,0,5)
, useLabel(CT_v10452)
,	/* FN_Data_46Sequence_46addDigits1: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(123),BOT(123),TOP(257),BOT(257))
,	/* v10423: (byte 2) */
  bytes2word(TOP(402),BOT(402),UNPACK,1)
, bytes2word(PUSH_ARG,4,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(26),BOT(26),TOP(52),BOT(52))
,	/* v10425: (byte 2) */
  bytes2word(TOP(79),BOT(79),UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1,HEAP_ARG)
, bytes2word(3,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_OFF_N1)
,	/* v10426: (byte 4) */
  bytes2word(7,HEAP_ARG,5,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(0,HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(10,HEAP_OFF_N1,7,HEAP_ARG)
,	/* v10427: (byte 2) */
  bytes2word(5,RETURN_EVAL,UNPACK,3)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,3)
, bytes2word(HEAP_ARG,3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,11)
, bytes2word(HEAP_OFF_N1,7,HEAP_ARG,5)
,	/* v10428: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,4,HEAP_ARG)
, bytes2word(3,HEAP_P1,0,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_I1,HEAP_I2,HEAP_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,12)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,5)
,	/* v10429: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,PUSH_ARG)
, bytes2word(4,EVAL,NEEDHEAP_I32,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(34),BOT(34),TOP(61),BOT(61))
,	/* v10431: (byte 2) */
  bytes2word(TOP(89),BOT(89),UNPACK,1)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,3,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,10,HEAP_OFF_N1)
,	/* v10432: (byte 4) */
  bytes2word(7,HEAP_ARG,5,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,7)
,	/* v10433: (byte 3) */
  bytes2word(HEAP_ARG,5,RETURN_EVAL,UNPACK)
, bytes2word(3,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(3,HEAP_P1,4,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(0,HEAP_I1,HEAP_I2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,8)
,	/* v10434: (byte 3) */
  bytes2word(HEAP_ARG,5,RETURN_EVAL,UNPACK)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(4,HEAP_P1,5,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_I2,HEAP_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,15)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,8)
,	/* v10435: (byte 3) */
  bytes2word(HEAP_ARG,5,RETURN_EVAL,UNPACK)
, bytes2word(3,PUSH_ARG,4,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,4,NOP)
, bytes2word(TOP(8),BOT(8),TOP(35),BOT(35))
,	/* v10437: (byte 4) */
  bytes2word(TOP(63),BOT(63),TOP(99),BOT(99))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(3,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,7)
,	/* v10438: (byte 3) */
  bytes2word(HEAP_ARG,5,RETURN_EVAL,UNPACK)
, bytes2word(2,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I2)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG,3)
, bytes2word(HEAP_P1,0,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,12,HEAP_OFF_N1,8)
,	/* v10439: (byte 3) */
  bytes2word(HEAP_ARG,5,RETURN_EVAL,UNPACK)
, bytes2word(3,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(3,HEAP_P1,4,HEAP_P1)
, bytes2word(5,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,15)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,8)
,	/* v10440: (byte 3) */
  bytes2word(HEAP_ARG,5,RETURN_EVAL,UNPACK)
, bytes2word(4,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(4,HEAP_P1,5,HEAP_P1)
, bytes2word(6,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(3,HEAP_P1,0,HEAP_I1)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I2)
, bytes2word(HEAP_P1,3,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(16,HEAP_OFF_N1,12,HEAP_OFF_N1)
,	/* v10441: (byte 4) */
  bytes2word(8,HEAP_ARG,5,RETURN_EVAL)
, bytes2word(UNPACK,4,PUSH_ZAP_ARG,4)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,4)
, bytes2word(TOP(8),BOT(8),TOP(36),BOT(36))
,	/* v10443: (byte 4) */
  bytes2word(TOP(72),BOT(72),TOP(109),BOT(109))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,4)
, bytes2word(HEAP_ARG,3,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,12,HEAP_OFF_N1)
,	/* v10444: (byte 4) */
  bytes2word(8,HEAP_ARG,5,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,HEAP_P1)
, bytes2word(4,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,5,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(0,HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(15,HEAP_OFF_N1,11,HEAP_OFF_N1)
,	/* v10445: (byte 4) */
  bytes2word(8,HEAP_ARG,5,RETURN_EVAL)
, bytes2word(UNPACK,3,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,6,HEAP_ARG,3)
, bytes2word(HEAP_P1,0,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_I1,HEAP_I2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,16,HEAP_OFF_N1,12)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,5)
,	/* v10446: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,4,HEAP_P1)
, bytes2word(5,HEAP_P1,6,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,7,HEAP_ARG)
, bytes2word(3,HEAP_P1,0,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_I1,HEAP_I2,HEAP_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,17)
, bytes2word(HEAP_OFF_N1,13,HEAP_OFF_N1,9)
, bytes2word(HEAP_ARG,5,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10452: (byte 0) */
  HW(6,5)
, 0
,	/* F0_Data_46Sequence_46addDigits1: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46addDigits1),5)
, VAPTAG(useLabel(FN_Data_46Sequence_46node3))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node)
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree1))
, VAPTAG(useLabel(FN_Data_46Sequence_46node2))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree2))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree3))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v10483)
,	/* FN_Data_46Sequence_46addDigits0: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(109),BOT(109),TOP(223),BOT(223))
,	/* v10454: (byte 2) */
  bytes2word(TOP(354),BOT(354),UNPACK,1)
, bytes2word(PUSH_ARG_I3,EVAL,NEEDHEAP_I32,TABLESWITCH)
, bytes2word(4,NOP,TOP(8),BOT(8))
, bytes2word(TOP(24),BOT(24),TOP(42),BOT(42))
,	/* v10456: (byte 2) */
  bytes2word(TOP(66),BOT(66),UNPACK,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,6,HEAP_ARG)
,	/* v10457: (byte 2) */
  bytes2word(4,RETURN_EVAL,UNPACK,2)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I2)
, bytes2word(HEAP_P1,0,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_OFF_N1)
,	/* v10458: (byte 4) */
  bytes2word(7,HEAP_ARG,4,RETURN_EVAL)
, bytes2word(UNPACK,3,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1,HEAP_I2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,10,HEAP_OFF_N1)
,	/* v10459: (byte 4) */
  bytes2word(7,HEAP_ARG,4,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,4,HEAP_P1)
, bytes2word(0,HEAP_I1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,7)
,	/* v10460: (byte 3) */
  bytes2word(HEAP_ARG,4,RETURN_EVAL,UNPACK)
, bytes2word(2,PUSH_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(26),BOT(26),TOP(50),BOT(50))
,	/* v10462: (byte 2) */
  bytes2word(TOP(77),BOT(77),UNPACK,1)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_I4,HEAP_I1)
, bytes2word(HEAP_I2,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_OFF_N1)
,	/* v10463: (byte 4) */
  bytes2word(7,HEAP_ARG,4,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,10,HEAP_OFF_N1)
,	/* v10464: (byte 4) */
  bytes2word(7,HEAP_ARG,4,RETURN_EVAL)
, bytes2word(UNPACK,3,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,3,HEAP_P1)
, bytes2word(4,HEAP_P1,0,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_I1,HEAP_I2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,7)
,	/* v10465: (byte 3) */
  bytes2word(HEAP_ARG,4,RETURN_EVAL,UNPACK)
, bytes2word(4,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,4,HEAP_P1,5)
, bytes2word(HEAP_P1,0,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_I1,HEAP_I2,HEAP_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,12)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,4)
,	/* v10466: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,3,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,4)
, bytes2word(TOP(8),BOT(8),TOP(32),BOT(32))
,	/* v10468: (byte 4) */
  bytes2word(TOP(59),BOT(59),TOP(89),BOT(89))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,3,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,10,HEAP_OFF_N1)
,	/* v10469: (byte 4) */
  bytes2word(7,HEAP_ARG,4,RETURN_EVAL)
, bytes2word(UNPACK,2,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_P1,3)
, bytes2word(HEAP_P1,4,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_I1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,7)
,	/* v10470: (byte 3) */
  bytes2word(HEAP_ARG,4,RETURN_EVAL,UNPACK)
, bytes2word(3,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,3,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,0,HEAP_I1)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,12)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,4)
,	/* v10471: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_P1,4)
, bytes2word(HEAP_P1,5,HEAP_P1,6)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,0)
, bytes2word(HEAP_I1,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I2)
, bytes2word(HEAP_P1,3,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(15,HEAP_OFF_N1,11,HEAP_OFF_N1)
,	/* v10472: (byte 4) */
  bytes2word(8,HEAP_ARG,4,RETURN_EVAL)
, bytes2word(UNPACK,4,PUSH_ZAP_ARG_I3,EVAL)
, bytes2word(NEEDHEAP_I32,TABLESWITCH,4,NOP)
, bytes2word(TOP(8),BOT(8),TOP(35),BOT(35))
,	/* v10474: (byte 4) */
  bytes2word(TOP(65),BOT(65),TOP(100),BOT(100))
, bytes2word(UNPACK,1,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_I1,HEAP_I2,HEAP_P1)
, bytes2word(3,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1)
, bytes2word(4,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,7)
,	/* v10475: (byte 3) */
  bytes2word(HEAP_ARG,4,RETURN_EVAL,UNPACK)
, bytes2word(2,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_I2,HEAP_P1,3,HEAP_P1)
, bytes2word(4,HEAP_CVAL_P1,6,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,5,HEAP_P1,0)
, bytes2word(HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,12)
, bytes2word(HEAP_OFF_N1,8,HEAP_ARG,4)
,	/* v10476: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,3,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_P1,3)
, bytes2word(HEAP_P1,4,HEAP_P1,5)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_P1,6)
, bytes2word(HEAP_P1,0,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_I1,HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(8,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(15,HEAP_OFF_N1,11,HEAP_OFF_N1)
,	/* v10477: (byte 4) */
  bytes2word(8,HEAP_ARG,4,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_I4,HEAP_P1,4,HEAP_P1)
, bytes2word(5,HEAP_P1,6,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_I4,HEAP_P1,7)
, bytes2word(HEAP_P1,0,HEAP_I1,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_I2,HEAP_P1,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_ARG)
, bytes2word(1,HEAP_OFF_N1,16,HEAP_OFF_N1)
, bytes2word(12,HEAP_OFF_N1,8,HEAP_ARG)
, bytes2word(4,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10483: (byte 0) */
  HW(6,4)
, 0
,	/* F0_Data_46Sequence_46addDigits0: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46addDigits0),4)
, VAPTAG(useLabel(FN_Data_46Sequence_46node2))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree1))
, VAPTAG(useLabel(FN_Data_46Sequence_46node3))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree2))
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree3))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10514)
,	/* FN_Data_46Sequence_46appendTree0: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I1,EVAL,TABLESWITCH)
, bytes2word(3,NOP,TOP(10),BOT(10))
,	/* v10508: (byte 4) */
  bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10487: (byte 4) */
  bytes2word(POP_I1,JUMP,5,0)
,	/* v10484: (byte 3) */
  bytes2word(POP_I1,PUSH_ARG_I2,RETURN_EVAL,PUSH_ARG_I2)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,3)
, bytes2word(TOP(10),BOT(10),TOP(6),BOT(6))
,	/* v10509: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10491: (byte 2) */
  bytes2word(5,0,POP_I1,PUSH_ARG_I1)
,	/* v10488: (byte 1) */
  bytes2word(RETURN,PUSH_ARG_I1,TABLESWITCH,3)
, bytes2word(TOP(6),BOT(6),TOP(10),BOT(10))
,	/* v10510: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10495: (byte 2) */
  bytes2word(11,0,UNPACK,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_I1)
,	/* v10492: (byte 3) */
  bytes2word(HEAP_ARG,2,RETURN_EVAL,PUSH_ARG_I2)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10511: (byte 4) */
  bytes2word(TOP(10),BOT(10),TOP(6),BOT(6))
,	/* v10499: (byte 4) */
  bytes2word(POP_I1,JUMP,11,0)
, bytes2word(UNPACK,1,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,HEAP_I1)
,	/* v10496: (byte 1) */
  bytes2word(RETURN_EVAL,PUSH_ARG_I1,TABLESWITCH,3)
, bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10512: (byte 2) */
  bytes2word(TOP(10),BOT(10),POP_I1,JUMP)
,	/* v10503: (byte 2) */
  bytes2word(51,0,UNPACK,4)
, bytes2word(PUSH_ARG_I2,TABLESWITCH,3,NOP)
, bytes2word(TOP(6),BOT(6),TOP(6),BOT(6))
,	/* v10513: (byte 2) */
  bytes2word(TOP(10),BOT(10),POP_I1,JUMP)
,	/* v10507: (byte 2) */
  bytes2word(30,0,UNPACK,4)
, bytes2word(HEAP_CVAL_P1,6,HEAP_P1,4)
, bytes2word(HEAP_P1,0,HEAP_CVAL_P1,7)
, bytes2word(HEAP_P1,6,HEAP_P1,7)
, bytes2word(HEAP_I1,HEAP_I2,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_OFF_N1,9,HEAP_P1)
, bytes2word(6,HEAP_OFF_N1,8,HEAP_P1)
,	/* v10504: (byte 2) */
  bytes2word(4,RETURN,POP_P1,4)
,	/* v10500: (byte 3) */
  bytes2word(JUMP,2,0,HEAP_CVAL_P1)
, bytes2word(8,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
,	/* CT_v10514: (byte 0) */
  HW(7,2)
, 0
,	/* F0_Data_46Sequence_46appendTree0: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46appendTree0),2)
, VAPTAG(useLabel(FN_Data_46Sequence_46consTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, VAPTAG(useLabel(FN_Data_46Sequence_46snocTree))
, VAPTAG(useLabel(FN_Prelude_46Num_46Prelude_46Int_46_43))
, VAPTAG(useLabel(FN_Data_46Sequence_46addDigits0))
, VAPTAG(useLabel(FN_LAMBDA9611))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10516)
,	/* FN_LAMBDA9611: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10515)
,	/* CT_v10516: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9611: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9611))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10517)
,};
Node FN_Data_46Sequence_46_62_60[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10517: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Data_46Sequence_46_62_60[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46_62_60),2)
, VAPTAG(useLabel(FN_Data_46Sequence_46appendTree0))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10518)
,};
Node FN_Data_46Sequence_46_60_124[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10518: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Sequence_46_60_124[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46_60_124),2)
, VAPTAG(useLabel(FN_Data_46Sequence_46consTree))
, useLabel(CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem)
, bytes2word(1,0,0,1)
, useLabel(CT_v10519)
,};
Node FN_Data_46Sequence_46singleton[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG,1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,1,0)
,	/* CT_v10519: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_Data_46Sequence_46singleton[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46singleton),1)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10520)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46traverse[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,2,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I5,HEAP_OFF_N1,6)
, bytes2word(HEAP_CVAL_P1,6,HEAP_OFF_N1,6)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10520: (byte 0) */
  HW(4,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46traverse[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46traverse),3)
, VAPTAG(useLabel(FN_Control_46Applicative_46Applicative_46Prelude_46Functor))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_36_62))
, useLabel(F0_NHC_46Internal_46_95id)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10521)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46sequence[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10521: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46sequence[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46sequence),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequence))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10522)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46mapM[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10522: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46mapM[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46mapM),3)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46mapM))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10523)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46sequenceA[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10523: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46sequenceA[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46sequenceA),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequenceA))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10524)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldl[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I3,PUSH_ARG_I2,PUSH_ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10524: (byte 0) */
  HW(0,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldl[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldl),3)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10525)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldr[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I2,PUSH_ARG_I3,PUSH_ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10525: (byte 0) */
  HW(0,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldr[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldr),3)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10526)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldl1[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10526: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldl1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldl1),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldl1))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10527)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldr1[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10527: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldr1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldr1),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldr1))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10528)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldMap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10528: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldMap[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldMap),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldMap))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10529)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46fold[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10529: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46fold[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46fold),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46fold))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10530)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46Elem_46fmap[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I2,PUSH_ZAP_ARG_I1,ZAP_ARG_I2)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,1)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10530: (byte 0) */
  HW(0,2)
, 0
,};
Node F0_Prelude_46Functor_46Data_46Sequence_46Elem_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Elem_46fmap),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v10531)
,};
Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46Elem_46size[] = {
  bytes2word(ZAP_ARG_I1,NEEDSTACK_I16,PUSH_INT_P1,1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10531: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_Data_46Sequence_46Sized_46Data_46Sequence_46Elem_46size[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Elem_46size),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v10532)
,	/* FN_Data_46Sequence_46getElem: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I1,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10532: (byte 0) */
  HW(0,1)
, 0
,	/* F0_Data_46Sequence_46getElem: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46getElem),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v10537)
,};
Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46Node_46size[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,TABLESWITCH)
, bytes2word(2,NOP,TOP(4),BOT(4))
,	/* v10534: (byte 2) */
  bytes2word(TOP(9),BOT(9),UNPACK,3)
,	/* v10535: (byte 3) */
  bytes2word(PUSH_P1,0,RETURN_EVAL,UNPACK)
, bytes2word(4,PUSH_P1,0,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10537: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_Data_46Sequence_46Sized_46Data_46Sequence_46Node_46size[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Node_46size),1)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10542)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46traverse[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10539: (byte 2) */
  bytes2word(TOP(53),BOT(53),UNPACK,3)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_CVAL_I4)
, bytes2word(HEAP_P1,0,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(2,HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(6,HEAP_OFF_N1,8,HEAP_OFF_N1)
, bytes2word(7,HEAP_OFF_N1,6,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,2,HEAP_P1)
, bytes2word(4,PUSH_P1,0,PUSH_P1)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_P1,7)
, bytes2word(HEAP_ARG,1,ZAP_STACK_P1,6)
, bytes2word(ZAP_STACK_P1,5,ZAP_STACK_P1,4)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
,	/* v10540: (byte 3) */
  bytes2word(APPLY,2,RETURN_EVAL,UNPACK)
, bytes2word(4,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_P1,8,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,2,HEAP_I1)
, bytes2word(HEAP_CVAL_P1,6,HEAP_OFF_N1,8)
, bytes2word(HEAP_OFF_N1,7,HEAP_OFF_N1,6)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,2,HEAP_I2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_OFF_N1)
, bytes2word(17,HEAP_OFF_N1,9,HEAP_OFF_N1)
, bytes2word(6,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(2,HEAP_P1,5,PUSH_P1)
, bytes2word(0,PUSH_P1,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1,8)
, bytes2word(ZAP_STACK_P1,7,ZAP_STACK_P1,6)
, bytes2word(ZAP_STACK_P1,5,ZAP_STACK_P1,4)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10542: (byte 0) */
  HW(7,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46traverse[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46traverse),3)
, VAPTAG(useLabel(FN_Control_46Applicative_46Applicative_46Prelude_46Functor))
, CAPTAG(useLabel(FN_LAMBDA9612),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_36_62))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_42_62))
, CAPTAG(useLabel(FN_LAMBDA9613),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v10543)
,	/* FN_LAMBDA9613: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG_ARG)
, bytes2word(3,4,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,4,0)
,	/* CT_v10543: (byte 0) */
  HW(0,4)
, 0
,	/* F0_LAMBDA9613: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9613),4)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10544)
,	/* FN_LAMBDA9612: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,3,0)
,	/* CT_v10544: (byte 0) */
  HW(0,3)
, 0
,	/* F0_LAMBDA9612: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9612),3)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10545)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46sequence[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10545: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46sequence[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46sequence),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequence))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Node)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10546)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46mapM[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10546: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46mapM[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46mapM),3)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46mapM))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Node)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10547)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46sequenceA[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10547: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46sequenceA[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46sequenceA),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequenceA))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Node)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10548)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46Node_46fmap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_ARG_I2,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10548: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Functor_46Data_46Sequence_46Node_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Node_46fmap),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46fmapDefault))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Node)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10553)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10550: (byte 2) */
  bytes2word(TOP(27),BOT(27),UNPACK,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_I2,PUSH_P1,3)
, bytes2word(PUSH_I1,PUSH_ARG_I1,ZAP_STACK_P1,5)
, bytes2word(ZAP_STACK_P1,4,ZAP_STACK_P1,3)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
,	/* v10551: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,6,HEAP_P1,3)
, bytes2word(PUSH_P1,4,PUSH_I1,PUSH_ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,ZAP_STACK_P1,7,ZAP_STACK_P1)
, bytes2word(6,ZAP_STACK_P1,5,ZAP_STACK_P1)
, bytes2word(4,ZAP_STACK_P1,3,EVAL)
, bytes2word(NEEDHEAP_I32,APPLY,2,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10553: (byte 0) */
  HW(1,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10558)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10555: (byte 2) */
  bytes2word(TOP(30),BOT(30),UNPACK,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_P1,3,HEAP_ARG,2)
, bytes2word(PUSH_P1,0,PUSH_P1,3)
, bytes2word(PUSH_ARG_I1,ZAP_STACK_P1,5,ZAP_STACK_P1)
, bytes2word(4,ZAP_STACK_P1,3,EVAL)
,	/* v10556: (byte 4) */
  bytes2word(NEEDHEAP_I32,APPLY,2,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_P1,3,HEAP_ARG)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_P1,3,HEAP_OFF_N1)
, bytes2word(7,PUSH_P1,0,PUSH_P1)
, bytes2word(3,PUSH_ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1)
, bytes2word(7,ZAP_STACK_P1,6,ZAP_STACK_P1)
, bytes2word(5,ZAP_STACK_P1,4,ZAP_STACK_P1)
, bytes2word(3,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10558: (byte 0) */
  HW(1,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10559)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl1[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10559: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl1),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldl1))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Node)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10560)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr1[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10560: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr1),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldr1))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Node)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10561)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldMap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10561: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldMap[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldMap),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldMap))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Node)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10562)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46fold[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10562: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46fold[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46fold),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46fold))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Node)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10563)
,};
Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit_46size[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_INT_P1,0,HEAP_ARG,2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10563: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Sequence_46Sized_46Data_46Sequence_46Digit_46size[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit_46size),2)
, CAPTAG(useLabel(FN_LAMBDA9614),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10564)
,	/* FN_LAMBDA9614: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,3,ZAP_ARG_I1,ZAP_ARG_I3)
, bytes2word(EVAL,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(ADD_W,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10564: (byte 0) */
  HW(2,3)
, 0
,	/* F0_LAMBDA9614: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9614),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10571)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46traverse[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_P1)
, bytes2word(33,TABLESWITCH,4,NOP)
, bytes2word(TOP(8),BOT(8),TOP(29),BOT(29))
,	/* v10566: (byte 4) */
  bytes2word(TOP(76),BOT(76),TOP(141),BOT(141))
, bytes2word(UNPACK,1,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(2,HEAP_P1,0,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,6,HEAP_OFF_N1,7)
, bytes2word(HEAP_OFF_N1,6,HEAP_OFF_N1,6)
,	/* v10567: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,2,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_OFF_N1,7,HEAP_OFF_N1,6)
, bytes2word(HEAP_OFF_N1,6,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,2,HEAP_P1,3)
, bytes2word(PUSH_P1,0,PUSH_P1,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_ARG)
, bytes2word(1,ZAP_STACK_P1,5,ZAP_STACK_P1)
, bytes2word(4,ZAP_STACK_P1,3,EVAL)
,	/* v10568: (byte 4) */
  bytes2word(NEEDHEAP_I32,APPLY,2,RETURN_EVAL)
, bytes2word(UNPACK,3,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_P1,9,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,2,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,6,HEAP_OFF_N1,7)
, bytes2word(HEAP_OFF_N1,6,HEAP_OFF_N1,6)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,2,HEAP_I1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,10,HEAP_OFF_N1)
, bytes2word(16,HEAP_OFF_N1,9,HEAP_OFF_N1)
, bytes2word(6,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(2,HEAP_P1,4,PUSH_P1)
, bytes2word(0,PUSH_P1,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(ZAP_STACK_P1,6,ZAP_STACK_P1,5)
, bytes2word(ZAP_STACK_P1,4,ZAP_STACK_P1,3)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
,	/* v10569: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_P1)
, bytes2word(8,HEAP_ARG,1,HEAP_CVAL_P1)
, bytes2word(8,HEAP_ARG,1,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,11)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,2,HEAP_P1)
, bytes2word(0,HEAP_CVAL_P1,6,HEAP_OFF_N1)
, bytes2word(7,HEAP_OFF_N1,6,HEAP_OFF_N1)
, bytes2word(6,HEAP_CVAL_I5,HEAP_ARG,2)
, bytes2word(HEAP_I1,HEAP_CVAL_P1,10,HEAP_OFF_N1)
, bytes2word(16,HEAP_OFF_N1,9,HEAP_OFF_N1)
, bytes2word(6,HEAP_CVAL_I5,HEAP_ARG,2)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1,10)
, bytes2word(HEAP_OFF_N1,25,HEAP_OFF_N1,9)
, bytes2word(HEAP_OFF_N1,6,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,2,HEAP_P1,5)
, bytes2word(PUSH_P1,0,PUSH_P1,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,8,HEAP_ARG)
, bytes2word(1,ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1)
, bytes2word(8,ZAP_STACK_P1,7,ZAP_STACK_P1)
, bytes2word(6,ZAP_STACK_P1,5,ZAP_STACK_P1)
, bytes2word(4,ZAP_STACK_P1,3,EVAL)
, bytes2word(NEEDHEAP_I32,APPLY,2,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10571: (byte 0) */
  HW(9,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46traverse[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46traverse),3)
, VAPTAG(useLabel(FN_Control_46Applicative_46Applicative_46Prelude_46Functor))
, CAPTAG(useLabel(FN_LAMBDA9615),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_36_62))
, CAPTAG(useLabel(FN_LAMBDA9616),2)
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_42_62))
, CAPTAG(useLabel(FN_LAMBDA9617),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, CAPTAG(useLabel(FN_LAMBDA9618),4)
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v10572)
,	/* FN_LAMBDA9618: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG_ARG)
, bytes2word(3,4,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(3,4,0)
,	/* CT_v10572: (byte 0) */
  HW(0,4)
, 0
,	/* F0_LAMBDA9618: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9618),4)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10573)
,	/* FN_LAMBDA9617: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,3,0)
,	/* CT_v10573: (byte 0) */
  HW(0,3)
, 0
,	/* F0_LAMBDA9617: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9617),3)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10574)
,	/* FN_LAMBDA9616: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,2,0)
,	/* CT_v10574: (byte 0) */
  HW(0,2)
, 0
,	/* F0_LAMBDA9616: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9616),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v10575)
,	/* FN_LAMBDA9615: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG,1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v10575: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA9615: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9615),1)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10576)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46sequence[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10576: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46sequence[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46sequence),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequence))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10577)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46mapM[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10577: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46mapM[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46mapM),3)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46mapM))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10578)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46sequenceA[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10578: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46sequenceA[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46sequenceA),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequenceA))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10579)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46Digit_46fmap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_ARG_I2,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10579: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Functor_46Data_46Sequence_46Digit_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Digit_46fmap),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46fmapDefault))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10586)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl1[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(13),BOT(13),TOP(25),BOT(25))
,	/* v10581: (byte 2) */
  bytes2word(TOP(48),BOT(48),UNPACK,1)
,	/* v10582: (byte 3) */
  bytes2word(PUSH_P1,0,RETURN_EVAL,UNPACK)
, bytes2word(2,PUSH_I1,PUSH_I1,PUSH_ARG_I1)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
,	/* v10583: (byte 3) */
  bytes2word(APPLY,2,RETURN_EVAL,UNPACK)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_I1,HEAP_I2,PUSH_P1)
, bytes2word(3,PUSH_I1,PUSH_ARG_I1,ZAP_STACK_P1)
, bytes2word(5,ZAP_STACK_P1,4,ZAP_STACK_P1)
, bytes2word(3,EVAL,NEEDHEAP_I32,APPLY)
,	/* v10584: (byte 2) */
  bytes2word(2,RETURN_EVAL,UNPACK,4)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_P1)
, bytes2word(0,HEAP_I1,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,6)
, bytes2word(HEAP_P1,3,PUSH_P1,4)
, bytes2word(PUSH_I1,PUSH_ZAP_ARG_I1,ZAP_STACK_P1,7)
, bytes2word(ZAP_STACK_P1,6,ZAP_STACK_P1,5)
, bytes2word(ZAP_STACK_P1,4,ZAP_STACK_P1,3)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10586: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl1),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10593)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr1[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(13),BOT(13),TOP(25),BOT(25))
,	/* v10588: (byte 2) */
  bytes2word(TOP(50),BOT(50),UNPACK,1)
,	/* v10589: (byte 3) */
  bytes2word(PUSH_P1,0,RETURN_EVAL,UNPACK)
, bytes2word(2,PUSH_I1,PUSH_I1,PUSH_ARG_I1)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
,	/* v10590: (byte 3) */
  bytes2word(APPLY,2,RETURN_EVAL,UNPACK)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_I2,HEAP_P1,3)
, bytes2word(PUSH_P1,0,PUSH_P1,2)
, bytes2word(PUSH_ARG_I1,ZAP_STACK_P1,5,ZAP_STACK_P1)
, bytes2word(4,ZAP_STACK_P1,3,EVAL)
,	/* v10591: (byte 4) */
  bytes2word(NEEDHEAP_I32,APPLY,2,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_I2,HEAP_P1,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_I2,HEAP_OFF_N1,7,PUSH_P1)
, bytes2word(0,PUSH_P1,2,PUSH_ZAP_ARG_I1)
, bytes2word(ZAP_STACK_P1,7,ZAP_STACK_P1,6)
, bytes2word(ZAP_STACK_P1,5,ZAP_STACK_P1,4)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10593: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr1),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10600)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(19),BOT(19),TOP(40),BOT(40))
,	/* v10595: (byte 2) */
  bytes2word(TOP(70),BOT(70),UNPACK,1)
, bytes2word(PUSH_P1,0,PUSH_ARG_I2,PUSH_ARG_I1)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
,	/* v10596: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG_ARG,1,2)
, bytes2word(HEAP_I1,PUSH_P1,2,PUSH_I1)
, bytes2word(PUSH_ARG_I1,ZAP_STACK_P1,4,ZAP_STACK_P1)
, bytes2word(3,EVAL,NEEDHEAP_I32,APPLY)
,	/* v10597: (byte 2) */
  bytes2word(2,RETURN_EVAL,UNPACK,3)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG_ARG,1,2)
, bytes2word(HEAP_P1,0,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,6)
, bytes2word(HEAP_I2,PUSH_P1,3,PUSH_I1)
, bytes2word(PUSH_ARG_I1,ZAP_STACK_P1,5,ZAP_STACK_P1)
, bytes2word(4,ZAP_STACK_P1,3,EVAL)
,	/* v10598: (byte 4) */
  bytes2word(NEEDHEAP_I32,APPLY,2,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,2,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(6,HEAP_I1,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,6)
, bytes2word(HEAP_P1,3,PUSH_P1,4)
, bytes2word(PUSH_I1,PUSH_ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1)
, bytes2word(7,ZAP_STACK_P1,6,ZAP_STACK_P1)
, bytes2word(5,ZAP_STACK_P1,4,ZAP_STACK_P1)
, bytes2word(3,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10600: (byte 0) */
  HW(1,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10607)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,4,TOP(8),BOT(8))
, bytes2word(TOP(18),BOT(18),TOP(41),BOT(41))
,	/* v10602: (byte 2) */
  bytes2word(TOP(72),BOT(72),UNPACK,1)
, bytes2word(PUSH_ARG_I2,PUSH_I1,PUSH_ARG_I1,EVAL)
,	/* v10603: (byte 4) */
  bytes2word(NEEDHEAP_I32,APPLY,2,RETURN_EVAL)
, bytes2word(UNPACK,2,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_I2,HEAP_ARG)
, bytes2word(2,PUSH_P1,0,PUSH_P1)
, bytes2word(2,PUSH_ARG_I1,ZAP_STACK_P1,4)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
,	/* v10604: (byte 3) */
  bytes2word(APPLY,2,RETURN_EVAL,UNPACK)
, bytes2word(3,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_I2,HEAP_ARG,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_I2)
, bytes2word(HEAP_OFF_N1,7,PUSH_P1,0)
, bytes2word(PUSH_P1,2,PUSH_ARG_I1,ZAP_STACK_P1)
, bytes2word(5,ZAP_STACK_P1,4,ZAP_STACK_P1)
, bytes2word(3,EVAL,NEEDHEAP_I32,APPLY)
,	/* v10605: (byte 2) */
  bytes2word(2,RETURN_EVAL,UNPACK,4)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_P1)
, bytes2word(3,HEAP_ARG,2,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_I2,HEAP_OFF_N1)
, bytes2word(7,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_I2,HEAP_OFF_N1,7)
, bytes2word(PUSH_P1,0,PUSH_P1,2)
, bytes2word(PUSH_ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1,7)
, bytes2word(ZAP_STACK_P1,6,ZAP_STACK_P1,5)
, bytes2word(ZAP_STACK_P1,4,ZAP_STACK_P1,3)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10607: (byte 0) */
  HW(1,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10608)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldMap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10608: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldMap[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldMap),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldMap))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10609)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46fold[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10609: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46fold[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46fold),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46fold))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10615)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46traverse[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10611: (byte 4) */
  bytes2word(TOP(18),BOT(18),TOP(41),BOT(41))
, bytes2word(POP_I1,PUSH_CVAL_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,EVAL)
,	/* v10612: (byte 4) */
  bytes2word(NEEDHEAP_I32,APPLY,1,RETURN_EVAL)
, bytes2word(UNPACK,1,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_P1,6,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,2,HEAP_P1)
, bytes2word(0,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_OFF_N1,7,HEAP_OFF_N1,6)
,	/* v10613: (byte 3) */
  bytes2word(HEAP_OFF_N1,6,RETURN_EVAL,UNPACK)
, bytes2word(4,HEAP_CVAL_P1,9,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_P1,10,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,11,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_I1,HEAP_CVAL_P1,8)
, bytes2word(HEAP_OFF_N1,9,HEAP_OFF_N1,8)
, bytes2word(HEAP_OFF_N1,7,HEAP_CVAL_P1,12)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_CVAL_P1)
, bytes2word(13,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(5,HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(14,HEAP_OFF_N1,22,HEAP_OFF_N1)
, bytes2word(13,HEAP_OFF_N1,7,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,11,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_P1,5,PUSH_P1)
, bytes2word(0,PUSH_P1,2,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,9,HEAP_ARG,1)
, bytes2word(ZAP_ARG_I1,ZAP_ARG_I2,ZAP_STACK_P1,8)
, bytes2word(ZAP_STACK_P1,7,ZAP_STACK_P1,6)
, bytes2word(ZAP_STACK_P1,5,ZAP_STACK_P1,4)
, bytes2word(ZAP_STACK_P1,3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10615: (byte 0) */
  HW(12,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46traverse[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46traverse),3)
, useLabel(C0_Data_46Sequence_46Empty)
, VAPTAG(useLabel(FN_Control_46Applicative_46pure))
, VAPTAG(useLabel(FN_Control_46Applicative_46Applicative_46Prelude_46Functor))
, CAPTAG(useLabel(FN_LAMBDA9619),1)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_36_62))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_42_62))
, CAPTAG(useLabel(FN_LAMBDA9620),3)
, VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46traverse))
, CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46traverse),1)
, VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46traverse))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, bytes2word(0,0,4,0)
, bytes2word(3,1,2,2)
, bytes2word(1,3,0,4)
, useLabel(CT_v10616)
,	/* FN_LAMBDA9620: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG_ARG)
, bytes2word(3,4,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
,	/* CT_v10616: (byte 0) */
  HW(0,4)
, 0
,	/* F0_LAMBDA9620: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9620),4)
, bytes2word(1,0,0,1)
, useLabel(CT_v10617)
,	/* FN_LAMBDA9619: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG,1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,1,0)
,	/* CT_v10617: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA9619: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9619),1)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10618)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46sequence[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10618: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46sequence[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46sequence),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequence))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10619)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46mapM[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10619: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46mapM[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46mapM),3)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46mapM))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10620)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46sequenceA[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10620: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46sequenceA[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46sequenceA),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequenceA))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10626)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46FingerTree_46fmap[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10622: (byte 4) */
  bytes2word(TOP(11),BOT(11),TOP(24),BOT(24))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10623: (byte 1) */
  bytes2word(RETURN,UNPACK,1,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,2,HEAP_OFF_N1)
,	/* v10624: (byte 2) */
  bytes2word(4,RETURN,UNPACK,4)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,HEAP_I1)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_CVAL_P1)
, bytes2word(6,HEAP_OFF_N1,3,HEAP_I2)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,HEAP_P1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_IN3,HEAP_I1)
, bytes2word(HEAP_OFF_N1,13,HEAP_OFF_N1,9)
, bytes2word(HEAP_OFF_N1,7,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,4,0)
, CONSTR(1,1,0)
, CONSTR(0,0,0)
,	/* CT_v10626: (byte 0) */
  HW(4,2)
, 0
,};
Node F0_Prelude_46Functor_46Data_46Sequence_46FingerTree_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46FingerTree_46fmap),2)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Digit_46fmap))
, CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Node_46fmap),1)
, VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46FingerTree_46fmap))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10632)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl1[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10628: (byte 4) */
  bytes2word(TOP(13),BOT(13),TOP(18),BOT(18))
, bytes2word(POP_I1,HEAP_CVAL_I3,PUSH_HEAP,HEAP_CVAL_I4)
,	/* v10629: (byte 3) */
  bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,UNPACK)
,	/* v10630: (byte 4) */
  bytes2word(1,PUSH_P1,0,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_P1,6,HEAP_ARG)
, bytes2word(1,HEAP_I1,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,6,HEAP_OFF_N1,5)
, bytes2word(HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,6)
, bytes2word(HEAP_P1,4,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10632: (byte 0) */
  HW(6,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl1),2)
, VAPTAG(useLabel(FN_LAMBDA9621))
, VAPTAG(useLabel(FN_Prelude_46error))
, CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl1))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl))
, bytes2word(0,0,0,0)
, useLabel(CT_v10634)
,	/* FN_LAMBDA9621: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10633)
,	/* CT_v10634: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9621: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9621))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10640)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr1[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10636: (byte 4) */
  bytes2word(TOP(13),BOT(13),TOP(18),BOT(18))
, bytes2word(POP_I1,HEAP_CVAL_I3,PUSH_HEAP,HEAP_CVAL_I4)
,	/* v10637: (byte 3) */
  bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,UNPACK)
,	/* v10638: (byte 4) */
  bytes2word(1,PUSH_P1,0,RETURN_EVAL)
, bytes2word(UNPACK,4,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_P1,6,HEAP_OFF_N1)
, bytes2word(3,HEAP_CVAL_P1,7,HEAP_ARG)
, bytes2word(1,HEAP_P1,3,HEAP_CVAL_P1)
, bytes2word(8,HEAP_OFF_N1,6,HEAP_OFF_N1)
, bytes2word(5,HEAP_I2,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(6,HEAP_I2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10640: (byte 0) */
  HW(7,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr1),2)
, VAPTAG(useLabel(FN_LAMBDA9622))
, VAPTAG(useLabel(FN_Prelude_46error))
, CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr),2)
, CAPTAG(useLabel(FN_Prelude_46flip),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr1))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr))
, bytes2word(0,0,0,0)
, useLabel(CT_v10642)
,	/* FN_LAMBDA9622: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10641)
,	/* CT_v10642: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9622: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9622))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10648)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10644: (byte 4) */
  bytes2word(TOP(9),BOT(9),TOP(20),BOT(20))
,	/* v10645: (byte 3) */
  bytes2word(POP_I1,PUSH_ARG_I2,RETURN_EVAL,UNPACK)
, bytes2word(1,PUSH_P1,0,PUSH_ARG_I2)
, bytes2word(PUSH_ARG_I1,EVAL,NEEDHEAP_I32,APPLY)
,	/* v10646: (byte 2) */
  bytes2word(2,RETURN_EVAL,UNPACK,4)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,1,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_I1)
, bytes2word(HEAP_CVAL_I5,HEAP_OFF_N1,7,HEAP_OFF_N1)
, bytes2word(6,HEAP_I2,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,6)
, bytes2word(HEAP_P1,4,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10648: (byte 0) */
  HW(3,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl),3)
, CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10654)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10650: (byte 4) */
  bytes2word(TOP(9),BOT(9),TOP(19),BOT(19))
,	/* v10651: (byte 3) */
  bytes2word(POP_I1,PUSH_ARG_I2,RETURN_EVAL,UNPACK)
, bytes2word(1,PUSH_ARG_I2,PUSH_I1,PUSH_ARG_I1)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
,	/* v10652: (byte 1) */
  bytes2word(RETURN_EVAL,UNPACK,4,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,HEAP_CVAL_I5,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_P1,3,HEAP_CVAL_P1)
, bytes2word(6,HEAP_OFF_N1,7,HEAP_OFF_N1)
, bytes2word(6,HEAP_I2,PUSH_HEAP,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,6)
, bytes2word(HEAP_I2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10654: (byte 0) */
  HW(4,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr),3)
, CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr),2)
, CAPTAG(useLabel(FN_Prelude_46flip),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr))
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10655)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldMap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10655: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldMap[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldMap),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldMap))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10656)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46fold[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10656: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46fold[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46fold),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46fold))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10662)
,};
Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10658: (byte 4) */
  bytes2word(TOP(10),BOT(10),TOP(24),BOT(24))
,	/* v10659: (byte 4) */
  bytes2word(POP_I1,PUSH_INT_P1,0,RETURN)
, bytes2word(UNPACK,1,PUSH_P1,0)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(ZAP_ARG_I1,EVAL,NEEDHEAP_I32,APPLY)
,	/* v10660: (byte 2) */
  bytes2word(1,RETURN_EVAL,UNPACK,4)
, bytes2word(PUSH_P1,0,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10662: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size),2)
, VAPTAG(useLabel(FN_Data_46Sequence_46size))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10663)
,};
Node FN_Data_46Typeable_46Typeable_46Data_46Sequence_46Seq_46typeOf[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10663: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Typeable_46Typeable_46Data_46Sequence_46Seq_46typeOf[] = {
  CAPTAG(useLabel(FN_Data_46Typeable_46Typeable_46Data_46Sequence_46Seq_46typeOf),2)
, VAPTAG(useLabel(FN_Data_46Typeable_46typeOfDefault))
, useLabel(CF_Data_46Typeable_46Typeable1_46Data_46Sequence_46Seq)
, bytes2word(0,0,0,0)
, useLabel(CT_v10664)
,	/* FN_Data_46Sequence_46seqTc: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10664: (byte 0) */
  HW(2,0)
, 0
,	/* CF_Data_46Sequence_46seqTc: (byte 0) */
  VAPTAG(useLabel(FN_Data_46Sequence_46seqTc))
, VAPTAG(useLabel(FN_LAMBDA9623))
, VAPTAG(useLabel(FN_Data_46Typeable_46mkTyCon))
, bytes2word(0,0,0,0)
, useLabel(CT_v10666)
,	/* FN_LAMBDA9623: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10665)
,	/* CT_v10666: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9623: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9623))
, bytes2word(1,0,0,1)
, useLabel(CT_v10667)
,};
Node FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46Seq_46typeOf1[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,HEAP_CVAL_N1,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,0,0)
,	/* CT_v10667: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Data_46Typeable_46Typeable1_46Data_46Sequence_46Seq_46typeOf1[] = {
  CAPTAG(useLabel(FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46Seq_46typeOf1),1)
, VAPTAG(useLabel(FN_Data_46Typeable_46mkTyConApp))
, useLabel(CF_Data_46Sequence_46seqTc)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10668)
,};
Node FN_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mappend[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10668: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mappend[] = {
  CAPTAG(useLabel(FN_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mappend),2)
, VAPTAG(useLabel(FN_Data_46Sequence_46_62_60))
, bytes2word(0,0,0,0)
, useLabel(CT_v10669)
,};
Node FN_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mempty[] = {
  bytes2word(NEEDSTACK_I16,PUSH_CVAL_P1,3,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10669: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mempty[] = {
  VAPTAG(useLabel(FN_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mempty))
, useLabel(CF_Data_46Sequence_46empty)
, bytes2word(1,0,0,1)
, useLabel(CT_v10670)
,};
Node FN_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mconcat[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10670: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mconcat[] = {
  CAPTAG(useLabel(FN_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mconcat),1)
, VAPTAG(useLabel(FN_Data_46Monoid_46_95_46mconcat))
, useLabel(CF_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10671)
,};
Node FN_Prelude_46Read_46Data_46Sequence_46Seq_46readsPrec[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_INT_P1,10,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(4,HEAP_CVAL_I5,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,6,HEAP_OFF_N1)
, bytes2word(5,HEAP_OFF_N1,4,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10671: (byte 0) */
  HW(4,2)
, 0
,};
Node F0_Prelude_46Read_46Data_46Sequence_46Seq_46readsPrec[] = {
  CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46Seq_46readsPrec),2)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46_62))
, CAPTAG(useLabel(FN_Prelude_46readParen),1)
, CAPTAG(useLabel(FN_LAMBDA9627),1)
, VAPTAG(useLabel(FN_Prelude_46_36))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10672)
,	/* FN_LAMBDA9627: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_OFF_N1,5,HEAP_OFF_N1)
, bytes2word(4,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10672: (byte 0) */
  HW(3,2)
, 0
,	/* F0_LAMBDA9627: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9627),2)
, VAPTAG(useLabel(FN_Prelude_46lex))
, CAPTAG(useLabel(FN_LAMBDA9626),1)
, VAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_91_93_46_62_62_61))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10763)
,	/* FN_LAMBDA9626: (byte 0) */
  bytes2word(NEEDSTACK_P1,19,PUSH_ZAP_ARG_I2,EVAL)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10746: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10680: (byte 4) */
  bytes2word(POP_I1,JUMP,64,1)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,LOOKUPSWITCH,1)
, bytes2word(TOP(102),BOT(102),TOP(10),BOT(10))
,	/* v10747: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10684: (byte 2) */
  bytes2word(41,1,POP_I1,PUSH_I1)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10748: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10688: (byte 4) */
  bytes2word(POP_I1,JUMP,27,1)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,LOOKUPSWITCH,1)
, bytes2word(TOP(114),BOT(114),TOP(10),BOT(10))
,	/* v10749: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10692: (byte 2) */
  bytes2word(4,1,POP_I1,PUSH_I1)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10750: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10696: (byte 4) */
  bytes2word(POP_I1,JUMP,246,0)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,LOOKUPSWITCH,1)
, bytes2word(TOP(111),BOT(111),TOP(10),BOT(10))
,	/* v10751: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10700: (byte 2) */
  bytes2word(223,0,POP_I1,PUSH_I1)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10752: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10704: (byte 4) */
  bytes2word(POP_I1,JUMP,209,0)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,LOOKUPSWITCH,1)
, bytes2word(TOP(109),BOT(109),TOP(10),BOT(10))
,	/* v10753: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10708: (byte 2) */
  bytes2word(186,0,POP_I1,PUSH_I1)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10754: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10712: (byte 4) */
  bytes2word(POP_I1,JUMP,172,0)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,LOOKUPSWITCH,1)
, bytes2word(TOP(76),BOT(76),TOP(10),BOT(10))
,	/* v10755: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10716: (byte 2) */
  bytes2word(149,0,POP_I1,PUSH_I1)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10756: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10720: (byte 4) */
  bytes2word(POP_I1,JUMP,135,0)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,LOOKUPSWITCH,1)
, bytes2word(TOP(105),BOT(105),TOP(10),BOT(10))
,	/* v10757: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10724: (byte 2) */
  bytes2word(112,0,POP_I1,PUSH_I1)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10758: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10728: (byte 4) */
  bytes2word(POP_I1,JUMP,98,0)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,LOOKUPSWITCH,1)
, bytes2word(TOP(115),BOT(115),TOP(10),BOT(10))
,	/* v10759: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10732: (byte 2) */
  bytes2word(75,0,POP_I1,PUSH_I1)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10760: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10736: (byte 4) */
  bytes2word(POP_I1,JUMP,61,0)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(EVAL,NEEDHEAP_I32,LOOKUPSWITCH,1)
, bytes2word(TOP(116),BOT(116),TOP(10),BOT(10))
,	/* v10761: (byte 2) */
  bytes2word(TOP(6),BOT(6),POP_I1,JUMP)
,	/* v10740: (byte 2) */
  bytes2word(38,0,POP_I1,PUSH_I1)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10762: (byte 4) */
  bytes2word(TOP(8),BOT(8),TOP(4),BOT(4))
,	/* v10744: (byte 4) */
  bytes2word(POP_I1,JUMP,24,0)
, bytes2word(POP_I1,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,17)
, bytes2word(HEAP_CVAL_P1,6,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_OFF_N1,5,HEAP_OFF_N1)
,	/* v10737: (byte 2) */
  bytes2word(3,RETURN_EVAL,POP_P1,2)
,	/* v10729: (byte 3) */
  bytes2word(JUMP,2,0,POP_P1)
,	/* v10721: (byte 4) */
  bytes2word(2,JUMP,2,0)
, bytes2word(POP_P1,2,JUMP,2)
,	/* v10713: (byte 1) */
  bytes2word(0,POP_P1,2,JUMP)
,	/* v10705: (byte 2) */
  bytes2word(2,0,POP_P1,2)
,	/* v10697: (byte 3) */
  bytes2word(JUMP,2,0,POP_P1)
,	/* v10689: (byte 4) */
  bytes2word(2,JUMP,2,0)
, bytes2word(POP_P1,2,JUMP,2)
,	/* v10681: (byte 1) */
  bytes2word(0,POP_P1,2,JUMP)
,	/* v10677: (byte 2) */
  bytes2word(2,0,POP_P1,2)
,	/* v10673: (byte 3) */
  bytes2word(JUMP,2,0,HEAP_CVAL_P1)
, bytes2word(8,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10763: (byte 0) */
  HW(7,2)
, 0
,	/* F0_LAMBDA9626: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9626),2)
, VAPTAG(useLabel(FN_Prelude_46Read_46Prelude_46_91_93))
, VAPTAG(useLabel(FN_Prelude_46reads))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, CAPTAG(useLabel(FN_LAMBDA9624),1)
, VAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_91_93_46_62_62_61))
, VAPTAG(useLabel(FN_LAMBDA9625))
, VAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_91_93_46fail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10765)
,	/* FN_LAMBDA9625: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10764)
,	/* CT_v10765: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9625: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9625))
, bytes2word(1,0,0,1)
, useLabel(CT_v10769)
,	/* FN_LAMBDA9624: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,2,HEAP_P1,0)
, bytes2word(HEAP_CVAL_N1,1,HEAP_OFF_N1,4)
, bytes2word(HEAP_I1,PUSH_HEAP,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(4,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v10769: (byte 0) */
  HW(3,1)
, 0
,	/* F0_LAMBDA9624: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9624),1)
, VAPTAG(useLabel(FN_Data_46Sequence_46fromList))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Monad_46Prelude_46_91_93_46return))
, bytes2word(1,0,0,1)
, useLabel(CT_v10770)
,};
Node FN_Prelude_46Read_46Data_46Sequence_46Seq_46readList[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10770: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Read_46Data_46Sequence_46Seq_46readList[] = {
  CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46Seq_46readList),1)
, VAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46readList))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10771)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46Seq_46showsPrec[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_INT_P1,10,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(4,HEAP_CVAL_I5,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,3)
, bytes2word(HEAP_OFF_N1,3,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,9)
, bytes2word(HEAP_OFF_N1,3,HEAP_CVAL_P1,10)
, bytes2word(HEAP_CVAL_P1,11,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,3,HEAP_ARG,3)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,8)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_P1,12)
, bytes2word(HEAP_OFF_N1,16,HEAP_OFF_N1,5)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,13,HEAP_OFF_N1)
, bytes2word(23,HEAP_OFF_N1,5,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10771: (byte 0) */
  HW(11,3)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46Seq_46showsPrec[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46showsPrec),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46_62))
, CAPTAG(useLabel(FN_Prelude_46showParen),1)
, VAPTAG(useLabel(FN_Prelude_46showString))
, VAPTAG(useLabel(FN_LAMBDA9628))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Show_46Prelude_46_91_93))
, VAPTAG(useLabel(FN_Prelude_46shows))
, VAPTAG(useLabel(FN_Data_46Foldable_46toList))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq)
, VAPTAG(useLabel(FN_Prelude_46_46))
, VAPTAG(useLabel(FN_Prelude_46_36))
, bytes2word(0,0,0,0)
, useLabel(CT_v10773)
,	/* FN_LAMBDA9628: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10772)
,	/* CT_v10773: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9628: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9628))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10774)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46Seq_46show[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10774: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46Seq_46show[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46show),2)
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46show))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10775)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46Seq_46showsType[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10775: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46Seq_46showsType[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46showsType),2)
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46showsType))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10776)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46Seq_46showList[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10776: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46Seq_46showList[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46showList),2)
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46showList))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10777)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46Seq_46compare[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(3,HEAP_ARG,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,6,HEAP_ARG,1)
, bytes2word(HEAP_OFF_N1,10,HEAP_OFF_N1,6)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10777: (byte 0) */
  HW(4,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46Seq_46compare[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46compare),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46toList))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46_91_93_46compare))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10778)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46Seq_46min[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10778: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46Seq_46min[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46min),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46min))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10779)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46Seq_46max[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10779: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46Seq_46max[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46max),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46max))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10780)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_62[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10780: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46Seq_46_62[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_62),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46_62))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10781)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_62_61[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10781: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46Seq_46_62_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_62_61),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46_62_61))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10782)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_60[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10782: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46Seq_46_60[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_60),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46_60))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10783)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_60_61[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10783: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46Seq_46_60_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_60_61),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46_60_61))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10784)
,};
Node FN_Prelude_46Eq_46Data_46Sequence_46Seq_46_61_61[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(HEAP_CVAL_I3,HEAP_ARG,3,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,5,HEAP_OFF_N1,4)
, bytes2word(HEAP_CVAL_I5,HEAP_CVAL_P1,6,HEAP_CVAL_P1)
, bytes2word(7,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_I5,HEAP_CVAL_P1,6)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_P1,8)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,10)
, bytes2word(HEAP_OFF_N1,6,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_OFF_N1,18,HEAP_OFF_N1)
, bytes2word(6,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10784: (byte 0) */
  HW(7,3)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Sequence_46Seq_46_61_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq_46_61_61),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46length))
, VAPTAG(useLabel(FN_Prelude_46Eq_46Prelude_46Int_46_61_61))
, VAPTAG(useLabel(FN_Data_46Foldable_46toList))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46Eq_46Prelude_46_91_93_46_61_61))
, VAPTAG(useLabel(FN_Prelude_46_38_38))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10785)
,};
Node FN_Prelude_46Eq_46Data_46Sequence_46Seq_46_47_61[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10785: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Sequence_46Seq_46_47_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq_46_47_61),3)
, VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq))
, VAPTAG(useLabel(FN_Prelude_46_95_46_47_61))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10786)
,};
Node FN_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq_46mplus[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(1,2,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10786: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq_46mplus[] = {
  CAPTAG(useLabel(FN_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq_46mplus),2)
, VAPTAG(useLabel(FN_Data_46Sequence_46_62_60))
, bytes2word(0,0,0,0)
, useLabel(CT_v10787)
,};
Node FN_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq_46mzero[] = {
  bytes2word(NEEDSTACK_I16,PUSH_CVAL_P1,3,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10787: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq_46mzero[] = {
  VAPTAG(useLabel(FN_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq_46mzero))
, useLabel(CF_Data_46Sequence_46empty)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10788)
,};
Node FN_Prelude_46Monad_46Data_46Sequence_46Seq_46_62_62_61[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(4,HEAP_CVAL_P1,6,HEAP_ARG)
, bytes2word(1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10788: (byte 0) */
  HW(4,2)
, 0
,};
Node F0_Prelude_46Monad_46Data_46Sequence_46Seq_46_62_62_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Data_46Sequence_46Seq_46_62_62_61),2)
, CAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46407_46add),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46foldl_39))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq)
, useLabel(CF_Data_46Sequence_46empty)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10789)
,	/* FN_Data_46Sequence_46Prelude_46407_46add: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG_ARG,1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(2,HEAP_OFF_N1,5,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10789: (byte 0) */
  HW(2,3)
, 0
,	/* F0_Data_46Sequence_46Prelude_46407_46add: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46407_46add),3)
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Data_46Sequence_46_62_60))
, bytes2word(1,0,0,1)
, useLabel(CT_v10790)
,};
Node FN_Prelude_46Monad_46Data_46Sequence_46Seq_46return[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10790: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Prelude_46Monad_46Data_46Sequence_46Seq_46return[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Data_46Sequence_46Seq_46return),1)
, VAPTAG(useLabel(FN_Data_46Sequence_46singleton))
, bytes2word(1,0,0,1)
, useLabel(CT_v10791)
,};
Node FN_Prelude_46Monad_46Data_46Sequence_46Seq_46fail[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10791: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Monad_46Data_46Sequence_46Seq_46fail[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Data_46Sequence_46Seq_46fail),1)
, VAPTAG(useLabel(FN_Prelude_46_95_46fail))
, useLabel(CF_Prelude_46Monad_46Data_46Sequence_46Seq)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10792)
,};
Node FN_Prelude_46Monad_46Data_46Sequence_46Seq_46_62_62[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10792: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Monad_46Data_46Sequence_46Seq_46_62_62[] = {
  CAPTAG(useLabel(FN_Prelude_46Monad_46Data_46Sequence_46Seq_46_62_62),2)
, VAPTAG(useLabel(FN_Prelude_46_95_46_62_62))
, useLabel(CF_Prelude_46Monad_46Data_46Sequence_46Seq)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10793)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46traverse[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG_ARG,1,2)
, bytes2word(HEAP_CVAL_I5,HEAP_ARG,1,HEAP_OFF_N1)
, bytes2word(5,HEAP_ARG,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,6,HEAP_OFF_N1,10)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,7)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10793: (byte 0) */
  HW(5,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46traverse[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46traverse),3)
, VAPTAG(useLabel(FN_Control_46Applicative_46Applicative_46Prelude_46Functor))
, CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46traverse),1)
, VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46traverse))
, VAPTAG(useLabel(FN_Control_46Applicative_46_60_36_62))
, useLabel(F0_NHC_46Internal_46_95id)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10794)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46sequence[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10794: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46sequence[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46sequence),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequence))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10795)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46mapM[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10795: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46mapM[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46mapM),3)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46mapM))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10796)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46sequenceA[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10796: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46sequenceA[] = {
  CAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46sequenceA),2)
, VAPTAG(useLabel(FN_Data_46Traversable_46_95_46sequenceA))
, useLabel(CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10797)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl1[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(4,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10797: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl1),2)
, CAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46397_46f_39),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl1))
, VAPTAG(useLabel(FN_Data_46Sequence_46getElem))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10798)
,	/* FN_Data_46Sequence_46Prelude_46397_46f_39: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I3,PUSH_ARG_I2,PUSH_ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10798: (byte 0) */
  HW(0,3)
, 0
,	/* F0_Data_46Sequence_46Prelude_46397_46f_39: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46397_46f_39),3)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10799)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr1[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,HEAP_ARG)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_I5,HEAP_OFF_N1)
, bytes2word(4,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10799: (byte 0) */
  HW(3,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr1[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr1),2)
, CAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46391_46f_39),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr1))
, VAPTAG(useLabel(FN_Data_46Sequence_46getElem))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10800)
,	/* FN_Data_46Sequence_46Prelude_46391_46f_39: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I3,PUSH_ARG_I2,PUSH_ZAP_ARG_I1)
, bytes2word(ZAP_ARG_I2,ZAP_ARG_I3,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10800: (byte 0) */
  HW(0,3)
, 0
,	/* F0_Data_46Sequence_46Prelude_46391_46f_39: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46391_46f_39),3)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10801)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10801: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl),3)
, CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldl),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10802)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_OFF_N1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I5,HEAP_OFF_N1,3,HEAP_ARG_ARG_RET_EVAL)
, bytes2word(2,3,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10802: (byte 0) */
  HW(3,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr),3)
, CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldr),2)
, CAPTAG(useLabel(FN_Prelude_46flip),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10803)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldMap[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG,1,2,HEAP_ARG)
, bytes2word(3,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10803: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldMap[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldMap),3)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46foldMap))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10804)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46fold[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,1,2,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10804: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46fold[] = {
  CAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46fold),2)
, VAPTAG(useLabel(FN_Data_46Foldable_46_95_46fold))
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq)
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10805)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46Seq_46fmap[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10805: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Functor_46Data_46Sequence_46Seq_46fmap[] = {
  CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Seq_46fmap),2)
, CAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Elem_46fmap),1)
, VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46FingerTree_46fmap))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10806)
,};
Node FN_Data_46Sequence_46_95_46size[] = {
  bytes2word(ZAP_ARG_I1,NEEDHEAP_I32,PUSH_ARG_I2,HEAP_CVAL_I3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,2)
, bytes2word(ZAP_ARG_I2,EVAL,NEEDHEAP_I32,APPLY)
, bytes2word(1,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
,	/* CT_v10806: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Data_46Sequence_46_95_46size[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46_95_46size),2)
, VAPTAG(useLabel(FN_LAMBDA9629))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95noMethodError))
, bytes2word(0,0,0,0)
, useLabel(CT_v10808)
,	/* FN_LAMBDA9629: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10807)
,	/* CT_v10808: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9629: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9629))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10809)
,};
Node FN_Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10809: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec[] = {
  CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec),2)
, CAPTAG(useLabel(FN_LAMBDA9633),1)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10810)
,	/* FN_LAMBDA9633: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,2,HEAP_ARG,3)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10810: (byte 0) */
  HW(1,3)
, 0
,	/* F0_LAMBDA9633: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9633),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec_392069))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10811)
,	/* FN_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec_392069: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,1,HEAP_OFF_N1,6)
, bytes2word(HEAP_ARG,2,HEAP_INT_P1,5)
, bytes2word(HEAP_INT_P1,6,HEAP_INT_P1,5)
, bytes2word(HEAP_OFF_N1,9,HEAP_OFF_N1,9)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,10)
, bytes2word(HEAP_ARG,3,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_N1,1,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_P1,9,HEAP_OFF_N1,4)
, bytes2word(HEAP_OFF_N1,4,HEAP_OFF_N1,4)
, bytes2word(HEAP_CVAL_P1,7,HEAP_OFF_N1,5)
, bytes2word(HEAP_ARG,3,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(10,HEAP_OFF_N1,14,HEAP_OFF_N1)
, bytes2word(5,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,0,0)
,	/* CT_v10811: (byte 0) */
  HW(8,3)
, 0
,	/* F0_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec_392069: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec_392069),3)
, VAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46Seq))
, CAPTAG(useLabel(FN_LAMBDA9630),2)
, VAPTAG(useLabel(FN_LAMBDA9631))
, VAPTAG(useLabel(FN_Prelude_46_95readConInfix))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_LAMBDA9632))
, VAPTAG(useLabel(FN_Prelude_46_95readCon0))
, VAPTAG(useLabel(FN_Prelude_46_43_43))
, bytes2word(0,0,0,0)
, useLabel(CT_v10813)
,	/* FN_LAMBDA9632: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10812)
,	/* CT_v10813: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9632: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9632))
, bytes2word(0,0,0,0)
, useLabel(CT_v10815)
,	/* FN_LAMBDA9631: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10814)
,	/* CT_v10815: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9631: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9631))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10816)
,	/* FN_LAMBDA9630: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,2,0)
,	/* CT_v10816: (byte 0) */
  HW(0,2)
, 0
,	/* F0_LAMBDA9630: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9630),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v10817)
,};
Node FN_Prelude_46Read_46Data_46Sequence_46ViewL_46readList[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10817: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Read_46Data_46Sequence_46ViewL_46readList[] = {
  CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewL_46readList),1)
, VAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewL))
, VAPTAG(useLabel(FN_Prelude_46_95_46readList))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10818)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewL_46showsType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,HEAP_CVAL_N1,1,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,3,HEAP_OFF_N1,3)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,2,HEAP_CHAR_P1,32)
, bytes2word(HEAP_CVAL_P1,9,HEAP_OFF_N1,8)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_P1,10)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,9,HEAP_OFF_N1,9)
, bytes2word(HEAP_OFF_N1,5,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(11,HEAP_OFF_N1,22,HEAP_OFF_N1)
, bytes2word(5,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,0,0)
,	/* CT_v10818: (byte 0) */
  HW(9,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewL_46showsType[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL_46showsType),2)
, VAPTAG(useLabel(FN_LAMBDA9635))
, VAPTAG(useLabel(FN_LAMBDA9636))
, VAPTAG(useLabel(FN_Prelude_46showString))
, VAPTAG(useLabel(FN_LAMBDA9637))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46showChar))
, VAPTAG(useLabel(FN_Prelude_46_46))
, VAPTAG(useLabel(FN_Prelude_46showsType))
, VAPTAG(useLabel(FN_Prelude_46showParen))
, bytes2word(0,0,0,0)
, useLabel(CT_v10819)
,	/* FN_LAMBDA9637: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10186)
,	/* CT_v10819: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9637: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9637))
, bytes2word(1,0,0,1)
, useLabel(CT_v10820)
,	/* FN_LAMBDA9636: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,1)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10820: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA9636: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9636),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v10826)
,	/* FN_LAMBDA9635: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10825: (byte 2) */
  bytes2word(TOP(8),BOT(8),POP_I1,JUMP)
,	/* v10824: (byte 2) */
  bytes2word(9,0,UNPACK,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_I1)
,	/* v10821: (byte 1) */
  bytes2word(RETURN,HEAP_CVAL_I3,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v10826: (byte 0) */
  HW(2,1)
, 0
,	/* F0_LAMBDA9635: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9635),1)
, VAPTAG(useLabel(FN_LAMBDA9634))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10828)
,	/* FN_LAMBDA9634: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10827)
,	/* CT_v10828: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9634: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9634))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10833)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewL_46showsPrec[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_P1)
, bytes2word(41,TABLESWITCH,2,NOP)
,	/* v10830: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(14),BOT(14))
, bytes2word(POP_I1,PUSH_CVAL_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I4,EVAL,NEEDHEAP_I32,APPLY)
,	/* v10831: (byte 2) */
  bytes2word(1,RETURN_EVAL,UNPACK,2)
, bytes2word(HEAP_CVAL_I5,HEAP_INT_P1,5,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_P1,6,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_P1,7,HEAP_OFF_N1)
, bytes2word(3,HEAP_INT_P1,6,HEAP_P1)
, bytes2word(0,HEAP_CVAL_P1,8,HEAP_CVAL_P1)
, bytes2word(9,HEAP_OFF_N1,2,HEAP_CHAR_P1)
, bytes2word(32,HEAP_CVAL_I4,HEAP_CVAL_P1,10)
, bytes2word(HEAP_CVAL_P1,9,HEAP_OFF_N1,3)
, bytes2word(HEAP_OFF_N1,3,HEAP_CVAL_P1,8)
, bytes2word(HEAP_CVAL_P1,9,HEAP_OFF_N1,2)
, bytes2word(HEAP_CHAR_P1,32,HEAP_CVAL_P1,11)
, bytes2word(HEAP_ARG,1,HEAP_INT_P1,5)
, bytes2word(HEAP_I1,HEAP_CVAL_P1,12,HEAP_OFF_N1)
, bytes2word(8,HEAP_OFF_N1,6,HEAP_CVAL_P1)
, bytes2word(12,HEAP_OFF_N1,15,HEAP_OFF_N1)
, bytes2word(5,HEAP_CVAL_P1,12,HEAP_OFF_N1)
, bytes2word(23,HEAP_OFF_N1,5,HEAP_CVAL_P1)
, bytes2word(12,HEAP_OFF_N1,31,HEAP_OFF_N1)
, bytes2word(5,PUSH_HEAP,HEAP_CVAL_P1,13)
, bytes2word(HEAP_OFF_N1,39,HEAP_OFF_N1,5)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10833: (byte 0) */
  HW(11,3)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewL_46showsPrec[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL_46showsPrec),3)
, useLabel(CF_LAMBDA9638)
, VAPTAG(useLabel(FN_Prelude_46showString))
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46_60))
, VAPTAG(useLabel(FN_Prelude_46showsPrec))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Prelude_46showChar))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_LAMBDA9639))
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46showsPrec))
, VAPTAG(useLabel(FN_Prelude_46_46))
, VAPTAG(useLabel(FN_Prelude_46showParen))
, bytes2word(0,0,0,0)
, useLabel(CT_v10834)
,	/* FN_LAMBDA9639: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10814)
,	/* CT_v10834: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9639: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9639))
, bytes2word(0,0,0,0)
, useLabel(CT_v10835)
,	/* FN_LAMBDA9638: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10812)
,	/* CT_v10835: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9638: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9638))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10836)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewL_46show[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10836: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewL_46show[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL_46show),2)
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL))
, VAPTAG(useLabel(FN_Prelude_46_95_46show))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10837)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewL_46showList[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10837: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewL_46showList[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL_46showList),2)
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL))
, VAPTAG(useLabel(FN_Prelude_46_95_46showList))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10859)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46compare[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(2,NOP,TOP(4),BOT(4))
,	/* v10841: (byte 2) */
  bytes2word(TOP(23),BOT(23),POP_I1,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10856: (byte 4) */
  bytes2word(TOP(8),BOT(8),TOP(4),BOT(4))
,	/* v10845: (byte 4) */
  bytes2word(POP_I1,JUMP,69,0)
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10846: (byte 1) */
  bytes2word(RETURN,UNPACK,2,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10857: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10850: (byte 4) */
  bytes2word(POP_I1,JUMP,44,0)
, bytes2word(UNPACK,2,PUSH_P1,0)
, bytes2word(PUSH_P1,3,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,EVAL,NEEDHEAP_I32)
, bytes2word(APPLY,2,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,3,TOP(6),BOT(6))
,	/* v10852: (byte 4) */
  bytes2word(TOP(11),BOT(11),TOP(20),BOT(20))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,2)
,	/* v10853: (byte 1) */
  bytes2word(RETURN,POP_I1,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_ARG,1,HEAP_P1,4)
,	/* v10854: (byte 2) */
  bytes2word(HEAP_I2,RETURN_EVAL,POP_I1,PUSH_HEAP)
,	/* v10847: (byte 2) */
  bytes2word(HEAP_CVAL_IN3,RETURN,POP_P1,2)
,	/* v10838: (byte 3) */
  bytes2word(JUMP,2,0,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,2,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_OFF_N1,5,HEAP_OFF_N1,4)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v10859: (byte 0) */
  HW(4,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewL_46compare[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46compare),3)
, VAPTAG(useLabel(FN_Prelude_46compare))
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46compare))
, VAPTAG(useLabel(FN_Prelude_46_95fromEnum))
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46compare))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10876)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_60_61[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(2,NOP,TOP(4),BOT(4))
,	/* v10863: (byte 2) */
  bytes2word(TOP(23),BOT(23),POP_I1,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10874: (byte 4) */
  bytes2word(TOP(8),BOT(8),TOP(4),BOT(4))
,	/* v10867: (byte 4) */
  bytes2word(POP_I1,JUMP,72,0)
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10868: (byte 1) */
  bytes2word(RETURN,UNPACK,2,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10875: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10872: (byte 4) */
  bytes2word(POP_I1,JUMP,47,0)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_I2,HEAP_P1,0,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,6)
, bytes2word(HEAP_OFF_N1,3,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,HEAP_I2,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,7,HEAP_ARG,1)
, bytes2word(HEAP_P1,3,HEAP_I1,HEAP_CVAL_P1)
, bytes2word(8,HEAP_OFF_N1,9,HEAP_OFF_N1)
, bytes2word(6,PUSH_HEAP,HEAP_CVAL_P1,9)
, bytes2word(HEAP_OFF_N1,20,HEAP_OFF_N1,5)
,	/* v10869: (byte 1) */
  bytes2word(RETURN_EVAL,POP_P1,2,JUMP)
,	/* v10860: (byte 2) */
  bytes2word(2,0,PUSH_ARG_I3,ORD)
, bytes2word(PUSH_ARG_I2,ORD,LE_W,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,0,0)
,	/* CT_v10876: (byte 0) */
  HW(7,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewL_46_60_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_60_61),3)
, VAPTAG(useLabel(FN_Prelude_46_60))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Eq))
, VAPTAG(useLabel(FN_Prelude_46_61_61))
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_60_61))
, VAPTAG(useLabel(FN_Prelude_46_38_38))
, VAPTAG(useLabel(FN_Prelude_46_124_124))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10877)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46min[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10877: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewL_46min[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46min),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL))
, VAPTAG(useLabel(FN_Prelude_46_95_46min))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10878)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46max[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10878: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewL_46max[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46max),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL))
, VAPTAG(useLabel(FN_Prelude_46_95_46max))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10879)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_62[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10879: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewL_46_62[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_62),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL))
, VAPTAG(useLabel(FN_Prelude_46_95_46_62))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10880)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_62_61[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10880: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewL_46_62_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_62_61),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL))
, VAPTAG(useLabel(FN_Prelude_46_95_46_62_61))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10881)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_60[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10881: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewL_46_60[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_60),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL))
, VAPTAG(useLabel(FN_Prelude_46_95_46_60))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10898)
,};
Node FN_Prelude_46Eq_46Data_46Sequence_46ViewL_46_61_61[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(2,NOP,TOP(4),BOT(4))
,	/* v10885: (byte 2) */
  bytes2word(TOP(23),BOT(23),POP_I1,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10896: (byte 4) */
  bytes2word(TOP(8),BOT(8),TOP(4),BOT(4))
,	/* v10889: (byte 4) */
  bytes2word(POP_I1,JUMP,52,0)
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10890: (byte 1) */
  bytes2word(RETURN,UNPACK,2,PUSH_ZAP_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10897: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10894: (byte 4) */
  bytes2word(POP_I1,JUMP,27,0)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_I2,HEAP_P1,0,HEAP_CVAL_I5)
, bytes2word(HEAP_ARG,1,HEAP_P1,3)
, bytes2word(HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_OFF_N1,9,HEAP_OFF_N1,6)
,	/* v10891: (byte 1) */
  bytes2word(RETURN_EVAL,POP_P1,2,JUMP)
,	/* v10882: (byte 2) */
  bytes2word(2,0,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v10898: (byte 0) */
  HW(4,3)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Sequence_46ViewL_46_61_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewL_46_61_61),3)
, VAPTAG(useLabel(FN_Prelude_46_61_61))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq_46_61_61))
, VAPTAG(useLabel(FN_Prelude_46_38_38))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10899)
,};
Node FN_Prelude_46Eq_46Data_46Sequence_46ViewL_46_47_61[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10899: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Sequence_46ViewL_46_47_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewL_46_47_61),3)
, VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewL))
, VAPTAG(useLabel(FN_Prelude_46_95_46_47_61))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10900)
,};
Node FN_Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,2,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10900: (byte 0) */
  HW(1,2)
, 0
,};
Node F0_Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec[] = {
  CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec),2)
, CAPTAG(useLabel(FN_LAMBDA9643),1)
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10901)
,	/* FN_LAMBDA9643: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG_ARG)
, bytes2word(1,2,HEAP_ARG,3)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10901: (byte 0) */
  HW(1,3)
, 0
,	/* F0_LAMBDA9643: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9643),3)
, VAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec_392052))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10902)
,	/* FN_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec_392052: (byte 0) */
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1,6)
, bytes2word(HEAP_OFF_N1,5,HEAP_ARG_ARG,1)
, bytes2word(2,HEAP_INT_P1,5,HEAP_INT_P1)
, bytes2word(5,HEAP_INT_P1,6,HEAP_OFF_N1)
, bytes2word(9,HEAP_OFF_N1,9,HEAP_CVAL_P1)
, bytes2word(7,HEAP_OFF_N1,10,HEAP_ARG)
, bytes2word(3,HEAP_CVAL_N1,1,HEAP_CVAL_N1)
, bytes2word(1,HEAP_CVAL_P1,8,HEAP_CVAL_P1)
, bytes2word(9,HEAP_OFF_N1,4,HEAP_OFF_N1)
, bytes2word(4,HEAP_OFF_N1,4,HEAP_CVAL_P1)
, bytes2word(7,HEAP_OFF_N1,5,HEAP_ARG)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_P1,10)
, bytes2word(HEAP_OFF_N1,14,HEAP_OFF_N1,5)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,0,0)
,	/* CT_v10902: (byte 0) */
  HW(8,3)
, 0
,	/* F0_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec_392052: (byte 0) */
  CAPTAG(useLabel(FN_Data_46Sequence_46Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec_392052),3)
, VAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46Seq))
, CAPTAG(useLabel(FN_LAMBDA9640),2)
, VAPTAG(useLabel(FN_LAMBDA9641))
, VAPTAG(useLabel(FN_Prelude_46_95readConInfix))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_LAMBDA9642))
, VAPTAG(useLabel(FN_Prelude_46_95readCon0))
, VAPTAG(useLabel(FN_Prelude_46_43_43))
, bytes2word(0,0,0,0)
, useLabel(CT_v10904)
,	/* FN_LAMBDA9642: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10903)
,	/* CT_v10904: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9642: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9642))
, bytes2word(0,0,0,0)
, useLabel(CT_v10906)
,	/* FN_LAMBDA9641: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10905)
,	/* CT_v10906: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9641: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9641))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10907)
,	/* FN_LAMBDA9640: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_ARG_ARG,1,2,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,2,0)
,	/* CT_v10907: (byte 0) */
  HW(0,2)
, 0
,	/* F0_LAMBDA9640: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9640),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v10908)
,};
Node FN_Prelude_46Read_46Data_46Sequence_46ViewR_46readList[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10908: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Read_46Data_46Sequence_46ViewR_46readList[] = {
  CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewR_46readList),1)
, VAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewR))
, VAPTAG(useLabel(FN_Prelude_46_95_46readList))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10909)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewR_46showsType[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(2,PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,HEAP_CVAL_N1,1,HEAP_CVAL_I5)
, bytes2word(HEAP_CVAL_P1,6,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,3,HEAP_OFF_N1,3)
, bytes2word(HEAP_CVAL_P1,8,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,2,HEAP_CHAR_P1,32)
, bytes2word(HEAP_CVAL_P1,9,HEAP_OFF_N1,8)
, bytes2word(HEAP_OFF_N1,5,HEAP_CVAL_P1,10)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,7)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,0)
, bytes2word(HEAP_CVAL_P1,9,HEAP_OFF_N1,9)
, bytes2word(HEAP_OFF_N1,5,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(11,HEAP_OFF_N1,22,HEAP_OFF_N1)
, bytes2word(5,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,0,0)
,	/* CT_v10909: (byte 0) */
  HW(9,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewR_46showsType[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR_46showsType),2)
, VAPTAG(useLabel(FN_LAMBDA9645))
, VAPTAG(useLabel(FN_LAMBDA9646))
, VAPTAG(useLabel(FN_Prelude_46showString))
, VAPTAG(useLabel(FN_LAMBDA9647))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_Prelude_46showChar))
, VAPTAG(useLabel(FN_Prelude_46_46))
, VAPTAG(useLabel(FN_Prelude_46showsType))
, VAPTAG(useLabel(FN_Prelude_46showParen))
, bytes2word(0,0,0,0)
, useLabel(CT_v10910)
,	/* FN_LAMBDA9647: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10146)
,	/* CT_v10910: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9647: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9647))
, bytes2word(1,0,0,1)
, useLabel(CT_v10911)
,	/* FN_LAMBDA9646: (byte 0) */
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,1)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10911: (byte 0) */
  HW(0,1)
, 0
,	/* F0_LAMBDA9646: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9646),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v10917)
,	/* FN_LAMBDA9645: (byte 0) */
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I1,EVAL,NEEDHEAP_I32)
, bytes2word(TABLESWITCH,2,TOP(4),BOT(4))
,	/* v10916: (byte 2) */
  bytes2word(TOP(8),BOT(8),POP_I1,JUMP)
,	/* v10915: (byte 2) */
  bytes2word(9,0,UNPACK,2)
, bytes2word(PUSH_HEAP,HEAP_CVAL_N1,1,HEAP_I2)
,	/* v10912: (byte 1) */
  bytes2word(RETURN,HEAP_CVAL_I3,PUSH_HEAP,HEAP_CVAL_I4)
, bytes2word(HEAP_OFF_N1,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v10917: (byte 0) */
  HW(2,1)
, 0
,	/* F0_LAMBDA9645: (byte 0) */
  CAPTAG(useLabel(FN_LAMBDA9645),1)
, VAPTAG(useLabel(FN_LAMBDA9644))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95patternMatchFail))
, bytes2word(0,0,0,0)
, useLabel(CT_v10919)
,	/* FN_LAMBDA9644: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10918)
,	/* CT_v10919: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9644: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9644))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10924)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewR_46showsPrec[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I3,EVAL,NEEDHEAP_P1)
, bytes2word(41,TABLESWITCH,2,NOP)
,	/* v10921: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(14),BOT(14))
, bytes2word(POP_I1,PUSH_CVAL_P1,3,PUSH_HEAP)
, bytes2word(HEAP_CVAL_I4,EVAL,NEEDHEAP_I32,APPLY)
,	/* v10922: (byte 2) */
  bytes2word(1,RETURN_EVAL,UNPACK,2)
, bytes2word(HEAP_CVAL_I5,HEAP_INT_P1,5,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_P1,6,HEAP_ARG)
, bytes2word(1,HEAP_INT_P1,5,HEAP_P1)
, bytes2word(0,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,HEAP_OFF_N1,2,HEAP_CHAR_P1)
, bytes2word(32,HEAP_CVAL_I4,HEAP_CVAL_P1,9)
, bytes2word(HEAP_CVAL_P1,8,HEAP_OFF_N1,3)
, bytes2word(HEAP_OFF_N1,3,HEAP_CVAL_P1,7)
, bytes2word(HEAP_CVAL_P1,8,HEAP_OFF_N1,2)
, bytes2word(HEAP_CHAR_P1,32,HEAP_CVAL_P1,10)
, bytes2word(HEAP_ARG,1,HEAP_CVAL_P1,11)
, bytes2word(HEAP_OFF_N1,3,HEAP_INT_P1,6)
, bytes2word(HEAP_I1,HEAP_CVAL_P1,12,HEAP_OFF_N1)
, bytes2word(10,HEAP_OFF_N1,6,HEAP_CVAL_P1)
, bytes2word(12,HEAP_OFF_N1,17,HEAP_OFF_N1)
, bytes2word(5,HEAP_CVAL_P1,12,HEAP_OFF_N1)
, bytes2word(25,HEAP_OFF_N1,5,HEAP_CVAL_P1)
, bytes2word(12,HEAP_OFF_N1,33,HEAP_OFF_N1)
, bytes2word(5,PUSH_HEAP,HEAP_CVAL_P1,13)
, bytes2word(HEAP_OFF_N1,39,HEAP_OFF_N1,5)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10924: (byte 0) */
  HW(11,3)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewR_46showsPrec[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR_46showsPrec),3)
, useLabel(CF_LAMBDA9648)
, VAPTAG(useLabel(FN_Prelude_46showString))
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46_60))
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46showsPrec))
, VAPTAG(useLabel(FN_Prelude_46showChar))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply1))
, VAPTAG(useLabel(FN_LAMBDA9649))
, VAPTAG(useLabel(FN_Prelude_46showsPrec))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Prelude_46_46))
, VAPTAG(useLabel(FN_Prelude_46showParen))
, bytes2word(0,0,0,0)
, useLabel(CT_v10925)
,	/* FN_LAMBDA9649: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10905)
,	/* CT_v10925: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9649: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9649))
, bytes2word(0,0,0,0)
, useLabel(CT_v10926)
,	/* FN_LAMBDA9648: (byte 0) */
  bytes2word(NEEDHEAP_I32,PUSH_CADR_N1,2,STRING)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, CONSTRW(1,0)
, useLabel(ST_v10903)
,	/* CT_v10926: (byte 0) */
  HW(0,0)
, 0
,	/* CF_LAMBDA9648: (byte 0) */
  VAPTAG(useLabel(FN_LAMBDA9648))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10927)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewR_46show[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10927: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewR_46show[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR_46show),2)
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR))
, VAPTAG(useLabel(FN_Prelude_46_95_46show))
, bytes2word(0,0,2,0)
, bytes2word(1,1,0,2)
, useLabel(CT_v10928)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewR_46showList[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG,2,RETURN_EVAL,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10928: (byte 0) */
  HW(2,2)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewR_46showList[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR_46showList),2)
, VAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR))
, VAPTAG(useLabel(FN_Prelude_46_95_46showList))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10950)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46compare[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(2,NOP,TOP(4),BOT(4))
,	/* v10932: (byte 2) */
  bytes2word(TOP(23),BOT(23),POP_I1,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10947: (byte 4) */
  bytes2word(TOP(8),BOT(8),TOP(4),BOT(4))
,	/* v10936: (byte 4) */
  bytes2word(POP_I1,JUMP,72,0)
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10937: (byte 1) */
  bytes2word(RETURN,UNPACK,2,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10948: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10941: (byte 4) */
  bytes2word(POP_I1,JUMP,47,0)
, bytes2word(UNPACK,2,PUSH_HEAP,HEAP_CVAL_I3)
, bytes2word(HEAP_ARG,1,HEAP_P1,3)
, bytes2word(HEAP_I1,EVAL,NEEDHEAP_I32,TABLESWITCH)
, bytes2word(3,NOP,TOP(6),BOT(6))
,	/* v10943: (byte 4) */
  bytes2word(TOP(11),BOT(11),TOP(27),BOT(27))
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,2)
,	/* v10944: (byte 1) */
  bytes2word(RETURN,POP_I1,PUSH_I1,PUSH_P1)
, bytes2word(4,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,ZAP_ARG_I1,ZAP_STACK_P1,4)
, bytes2word(EVAL,NEEDHEAP_I32,APPLY,2)
,	/* v10945: (byte 1) */
  bytes2word(RETURN_EVAL,POP_I1,PUSH_HEAP,HEAP_CVAL_IN3)
,	/* v10938: (byte 1) */
  bytes2word(RETURN,POP_P1,2,JUMP)
,	/* v10929: (byte 2) */
  bytes2word(2,0,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(2,HEAP_CVAL_I5,HEAP_ARG,3)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,6,HEAP_OFF_N1)
, bytes2word(5,HEAP_OFF_N1,4,RETURN_EVAL)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(2,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v10950: (byte 0) */
  HW(4,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewR_46compare[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46compare),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46compare))
, VAPTAG(useLabel(FN_Prelude_46compare))
, VAPTAG(useLabel(FN_Prelude_46_95fromEnum))
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Int_46compare))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10967)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_60_61[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(2,NOP,TOP(4),BOT(4))
,	/* v10954: (byte 2) */
  bytes2word(TOP(23),BOT(23),POP_I1,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10965: (byte 4) */
  bytes2word(TOP(8),BOT(8),TOP(4),BOT(4))
,	/* v10958: (byte 4) */
  bytes2word(POP_I1,JUMP,69,0)
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10959: (byte 1) */
  bytes2word(RETURN,UNPACK,2,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10966: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10963: (byte 4) */
  bytes2word(POP_I1,JUMP,44,0)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_I2,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_I2,HEAP_P1)
, bytes2word(0,HEAP_CVAL_P1,6,HEAP_ARG)
, bytes2word(1,HEAP_CVAL_P1,7,HEAP_OFF_N1)
, bytes2word(3,HEAP_P1,3,HEAP_I1)
, bytes2word(HEAP_CVAL_P1,8,HEAP_OFF_N1,11)
, bytes2word(HEAP_OFF_N1,6,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(9,HEAP_OFF_N1,20,HEAP_OFF_N1)
,	/* v10960: (byte 2) */
  bytes2word(5,RETURN_EVAL,POP_P1,2)
,	/* v10951: (byte 3) */
  bytes2word(JUMP,2,0,PUSH_ARG_I3)
, bytes2word(ORD,PUSH_ARG_I2,ORD,LE_W)
, bytes2word(RETURN_EVAL,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(1,0,0)
,	/* CT_v10967: (byte 0) */
  HW(7,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewR_46_60_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_60_61),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_60))
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Eq))
, VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq_46_61_61))
, VAPTAG(useLabel(FN_Prelude_46_60_61))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Prelude_46_38_38))
, VAPTAG(useLabel(FN_Prelude_46_124_124))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10968)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46min[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10968: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewR_46min[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46min),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR))
, VAPTAG(useLabel(FN_Prelude_46_95_46min))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10969)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46max[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10969: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewR_46max[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46max),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR))
, VAPTAG(useLabel(FN_Prelude_46_95_46max))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10970)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_62[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10970: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewR_46_62[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_62),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR))
, VAPTAG(useLabel(FN_Prelude_46_95_46_62))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10971)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_62_61[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10971: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewR_46_62_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_62_61),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR))
, VAPTAG(useLabel(FN_Prelude_46_95_46_62_61))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10972)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_60[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10972: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewR_46_60[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_60),3)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR))
, VAPTAG(useLabel(FN_Prelude_46_95_46_60))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10989)
,};
Node FN_Prelude_46Eq_46Data_46Sequence_46ViewR_46_61_61[] = {
  bytes2word(NEEDSTACK_I16,PUSH_ZAP_ARG_I2,EVAL,TABLESWITCH)
, bytes2word(2,NOP,TOP(4),BOT(4))
,	/* v10976: (byte 2) */
  bytes2word(TOP(23),BOT(23),POP_I1,PUSH_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10987: (byte 4) */
  bytes2word(TOP(8),BOT(8),TOP(4),BOT(4))
,	/* v10980: (byte 4) */
  bytes2word(POP_I1,JUMP,52,0)
, bytes2word(POP_I1,PUSH_HEAP,HEAP_CVAL_N1,1)
,	/* v10981: (byte 1) */
  bytes2word(RETURN,UNPACK,2,PUSH_ZAP_ARG_I3)
, bytes2word(EVAL,NEEDHEAP_I32,TABLESWITCH,2)
,	/* v10988: (byte 4) */
  bytes2word(TOP(4),BOT(4),TOP(8),BOT(8))
,	/* v10985: (byte 4) */
  bytes2word(POP_I1,JUMP,27,0)
, bytes2word(UNPACK,2,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,HEAP_I2,HEAP_P1,0)
, bytes2word(HEAP_CVAL_I4,HEAP_ARG,1,HEAP_CVAL_I5)
, bytes2word(HEAP_OFF_N1,3,HEAP_P1,3)
, bytes2word(HEAP_I1,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_OFF_N1,11,HEAP_OFF_N1,6)
,	/* v10982: (byte 1) */
  bytes2word(RETURN_EVAL,POP_P1,2,JUMP)
,	/* v10973: (byte 2) */
  bytes2word(2,0,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(2,RETURN_EVAL,ENDCODE,0)
, bytes2word(0,0,0,0)
, CONSTR(0,0,0)
, CONSTR(1,0,0)
,	/* CT_v10989: (byte 0) */
  HW(4,3)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Sequence_46ViewR_46_61_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewR_46_61_61),3)
, VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq_46_61_61))
, VAPTAG(useLabel(FN_Prelude_46_61_61))
, VAPTAG(useLabel(FN_NHC_46Internal_46_95apply2))
, VAPTAG(useLabel(FN_Prelude_46_38_38))
, bytes2word(3,0,2,1)
, bytes2word(1,2,0,3)
, useLabel(CT_v10990)
,};
Node FN_Prelude_46Eq_46Data_46Sequence_46ViewR_46_47_61[] = {
  bytes2word(NEEDHEAP_I32,HEAP_CVAL_I3,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1,3)
, bytes2word(HEAP_ARG_ARG_RET_EVAL,2,3,ENDCODE)
, bytes2word(0,0,0,0)
,	/* CT_v10990: (byte 0) */
  HW(2,3)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Sequence_46ViewR_46_47_61[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewR_46_47_61),3)
, VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewR))
, VAPTAG(useLabel(FN_Prelude_46_95_46_47_61))
, bytes2word(1,0,0,1)
, useLabel(CT_v10991)
,};
Node FN_Prelude_46Eq_46Data_46Sequence_46ViewR[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I2,HEAP_I1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v10991: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Sequence_46ViewR[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewR),1)
, CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewR_46_47_61),2)
, CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewR_46_61_61),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v10992)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewR[] = {
  bytes2word(NEEDHEAP_P1,36,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,10)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(11,HEAP_ARG,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_P1,8)
, bytes2word(HEAP_P1,7,HEAP_P1,6)
, bytes2word(HEAP_P1,5,HEAP_P1,4)
, bytes2word(HEAP_P1,3,HEAP_I2,HEAP_I1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,8,0)
,	/* CT_v10992: (byte 0) */
  HW(9,1)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewR[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR),1)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Eq))
, VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewR))
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_60),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_60_61),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_62_61),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46_62),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46compare),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46min),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewR_46max),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v10993)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewR[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_P1,4,HEAP_P1)
, bytes2word(3,HEAP_I2,HEAP_I1,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,4,0)
,	/* CT_v10993: (byte 0) */
  HW(4,1)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewR[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR_46showsPrec),2)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR_46showsType),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR_46showList),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewR_46show),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v10994)
,};
Node FN_Prelude_46Read_46Data_46Sequence_46ViewR[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I2,HEAP_I1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v10994: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Read_46Data_46Sequence_46ViewR[] = {
  CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewR),1)
, CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewR_46readsPrec),1)
, VAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewR_46readList))
, bytes2word(1,0,0,1)
, useLabel(CT_v10995)
,};
Node FN_Prelude_46Eq_46Data_46Sequence_46ViewL[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I2,HEAP_I1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v10995: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Sequence_46ViewL[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewL),1)
, CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewL_46_47_61),2)
, CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewL_46_61_61),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v10996)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46ViewL[] = {
  bytes2word(NEEDHEAP_P1,36,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,10)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(11,HEAP_ARG,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_P1,8)
, bytes2word(HEAP_P1,7,HEAP_P1,6)
, bytes2word(HEAP_P1,5,HEAP_P1,4)
, bytes2word(HEAP_P1,3,HEAP_I2,HEAP_I1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,8,0)
,	/* CT_v10996: (byte 0) */
  HW(9,1)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46ViewL[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL),1)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Eq))
, VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46ViewL))
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_60),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_60_61),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_62_61),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46_62),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46compare),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46min),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46ViewL_46max),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v10997)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46ViewL[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_P1,4,HEAP_P1)
, bytes2word(3,HEAP_I2,HEAP_I1,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,4,0)
,	/* CT_v10997: (byte 0) */
  HW(4,1)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46ViewL[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL_46showsPrec),2)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL_46showsType),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL_46showList),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46ViewL_46show),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v10998)
,};
Node FN_Prelude_46Read_46Data_46Sequence_46ViewL[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I2,HEAP_I1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v10998: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Read_46Data_46Sequence_46ViewL[] = {
  CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewL),1)
, CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewL_46readsPrec),1)
, VAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46ViewL_46readList))
, bytes2word(1,0,0,1)
, useLabel(CT_v10999)
,};
Node FN_Data_46Sequence_46size[] = {
  bytes2word(NEEDSTACK_I16,SELECTOR_EVAL,SELECT,1)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
,	/* CT_v10999: (byte 0) */
  HW(0,1)
, 0
,};
Node F0_Data_46Sequence_46size[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46size),1)
, bytes2word(0,0,0,0)
, useLabel(CT_v11000)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11000: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Data_46Sequence_46Seq[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Seq))
, useLabel(F0_Prelude_46Functor_46Data_46Sequence_46Seq_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v11001)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11001: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq[] = {
  VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq))
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46fold)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldl)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldMap)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq_46foldr)
, bytes2word(0,0,0,0)
, useLabel(CT_v11002)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11002: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq[] = {
  VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq))
, useLabel(CF_Prelude_46Functor_46Data_46Sequence_46Seq)
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Seq)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46sequenceA)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46mapM)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46sequence)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Seq_46traverse)
, bytes2word(0,0,0,0)
, useLabel(CT_v11003)
,};
Node FN_Prelude_46Monad_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,4,0)
,	/* CT_v11003: (byte 0) */
  HW(4,0)
, 0
,};
Node CF_Prelude_46Monad_46Data_46Sequence_46Seq[] = {
  VAPTAG(useLabel(FN_Prelude_46Monad_46Data_46Sequence_46Seq))
, useLabel(F0_Prelude_46Monad_46Data_46Sequence_46Seq_46_62_62_61)
, useLabel(F0_Prelude_46Monad_46Data_46Sequence_46Seq_46_62_62)
, useLabel(F0_Prelude_46Monad_46Data_46Sequence_46Seq_46fail)
, useLabel(F0_Prelude_46Monad_46Data_46Sequence_46Seq_46return)
, bytes2word(0,0,0,0)
, useLabel(CT_v11004)
,};
Node FN_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,3,0)
,	/* CT_v11004: (byte 0) */
  HW(3,0)
, 0
,};
Node CF_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq[] = {
  VAPTAG(useLabel(FN_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq))
, useLabel(CF_Prelude_46Monad_46Data_46Sequence_46Seq)
, useLabel(CF_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq_46mzero)
, useLabel(F0_Control_46Monad_46MonadPlus_46Data_46Sequence_46Seq_46mplus)
, bytes2word(1,0,0,1)
, useLabel(CT_v11005)
,};
Node FN_Prelude_46Eq_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I2,HEAP_I1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v11005: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Eq_46Data_46Sequence_46Seq[] = {
  CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq),1)
, CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq_46_47_61),2)
, CAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq_46_61_61),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v11006)
,};
Node FN_Prelude_46Ord_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_P1,36,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_OFF_N1)
, bytes2word(3,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(7,HEAP_ARG,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_P1,8,HEAP_ARG,1)
, bytes2word(PUSH_HEAP,HEAP_CVAL_P1,9,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,10)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_P1)
, bytes2word(11,HEAP_ARG,1,PUSH_HEAP)
, bytes2word(HEAP_CVAL_N1,1,HEAP_P1,8)
, bytes2word(HEAP_P1,7,HEAP_P1,6)
, bytes2word(HEAP_P1,5,HEAP_P1,4)
, bytes2word(HEAP_P1,3,HEAP_I2,HEAP_I1)
, bytes2word(RETURN,ENDCODE,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,8,0)
,	/* CT_v11006: (byte 0) */
  HW(9,1)
, 0
,};
Node F0_Prelude_46Ord_46Data_46Sequence_46Seq[] = {
  CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq),1)
, VAPTAG(useLabel(FN_Prelude_46Ord_46Prelude_46Eq))
, VAPTAG(useLabel(FN_Prelude_46Eq_46Data_46Sequence_46Seq))
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_60),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_60_61),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_62_61),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46_62),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46compare),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46min),2)
, CAPTAG(useLabel(FN_Prelude_46Ord_46Data_46Sequence_46Seq_46max),2)
, bytes2word(1,0,0,1)
, useLabel(CT_v11007)
,};
Node FN_Prelude_46Show_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I5,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_P1,6)
, bytes2word(HEAP_ARG,1,PUSH_HEAP,HEAP_CVAL_N1)
, bytes2word(1,HEAP_P1,4,HEAP_P1)
, bytes2word(3,HEAP_I2,HEAP_I1,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,4,0)
,	/* CT_v11007: (byte 0) */
  HW(4,1)
, 0
,};
Node F0_Prelude_46Show_46Data_46Sequence_46Seq[] = {
  CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46showsPrec),2)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46showsType),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46showList),1)
, CAPTAG(useLabel(FN_Prelude_46Show_46Data_46Sequence_46Seq_46show),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v11008)
,};
Node FN_Prelude_46Read_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_I4,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I2,HEAP_I1,RETURN,ENDCODE)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,2,0)
,	/* CT_v11008: (byte 0) */
  HW(2,1)
, 0
,};
Node F0_Prelude_46Read_46Data_46Sequence_46Seq[] = {
  CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46Seq),1)
, CAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46Seq_46readsPrec),1)
, VAPTAG(useLabel(FN_Prelude_46Read_46Data_46Sequence_46Seq_46readList))
, bytes2word(0,0,0,0)
, useLabel(CT_v11009)
,};
Node FN_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,RETURN)
, bytes2word(ENDCODE,0,0,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,3,0)
,	/* CT_v11009: (byte 0) */
  HW(3,0)
, 0
,};
Node CF_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq[] = {
  VAPTAG(useLabel(FN_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq))
, useLabel(F0_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mappend)
, useLabel(F0_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mconcat)
, useLabel(CF_Data_46Monoid_46Monoid_46Data_46Sequence_46Seq_46mempty)
, bytes2word(0,0,0,0)
, useLabel(CT_v11010)
,};
Node FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11010: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Data_46Typeable_46Typeable1_46Data_46Sequence_46Seq[] = {
  VAPTAG(useLabel(FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46Seq))
, useLabel(F0_Data_46Typeable_46Typeable1_46Data_46Sequence_46Seq_46typeOf1)
, bytes2word(1,0,0,1)
, useLabel(CT_v11011)
,};
Node FN_Data_46Typeable_46Typeable_46Data_46Sequence_46Seq[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I1,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11011: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Data_46Typeable_46Typeable_46Data_46Sequence_46Seq[] = {
  CAPTAG(useLabel(FN_Data_46Typeable_46Typeable_46Data_46Sequence_46Seq),1)
, CAPTAG(useLabel(FN_Data_46Typeable_46Typeable_46Data_46Sequence_46Seq_46typeOf),1)
, bytes2word(1,0,0,1)
, useLabel(CT_v11012)
,};
Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I1,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11012: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree),1)
, CAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46FingerTree_46size),1)
, bytes2word(0,0,0,0)
, useLabel(CT_v11013)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11013: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree[] = {
  VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree))
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46fold)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldl)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldMap)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree_46foldr)
, bytes2word(0,0,0,0)
, useLabel(CT_v11014)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46FingerTree[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11014: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Data_46Sequence_46FingerTree[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46FingerTree))
, useLabel(F0_Prelude_46Functor_46Data_46Sequence_46FingerTree_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v11015)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11015: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree[] = {
  VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree))
, useLabel(CF_Prelude_46Functor_46Data_46Sequence_46FingerTree)
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46FingerTree)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46sequenceA)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46mapM)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46sequence)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46FingerTree_46traverse)
, bytes2word(0,0,0,0)
, useLabel(CT_v11016)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11016: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit[] = {
  VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit))
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46fold)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldl)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldMap)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit_46foldr)
, bytes2word(0,0,0,0)
, useLabel(CT_v11017)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46Digit[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11017: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Data_46Sequence_46Digit[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Digit))
, useLabel(F0_Prelude_46Functor_46Data_46Sequence_46Digit_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v11018)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11018: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit[] = {
  VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit))
, useLabel(CF_Prelude_46Functor_46Data_46Sequence_46Digit)
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Digit)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46sequenceA)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46mapM)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46sequence)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Digit_46traverse)
, bytes2word(1,0,0,1)
, useLabel(CT_v11019)
,};
Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I1,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11019: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Data_46Sequence_46Sized_46Data_46Sequence_46Digit[] = {
  CAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit),1)
, CAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Digit_46size),1)
, bytes2word(0,0,0,0)
, useLabel(CT_v11020)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11020: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Node[] = {
  VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Node))
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46fold)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldl)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldMap)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Node_46foldr)
, bytes2word(0,0,0,0)
, useLabel(CT_v11021)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46Node[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11021: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Data_46Sequence_46Node[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Node))
, useLabel(F0_Prelude_46Functor_46Data_46Sequence_46Node_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v11022)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11022: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Node[] = {
  VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Node))
, useLabel(CF_Prelude_46Functor_46Data_46Sequence_46Node)
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Node)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46sequenceA)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46mapM)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46sequence)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Node_46traverse)
, bytes2word(0,0,0,0)
, useLabel(CT_v11023)
,};
Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46Node[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11023: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Data_46Sequence_46Sized_46Data_46Sequence_46Node[] = {
  VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Node))
, useLabel(F0_Data_46Sequence_46Sized_46Data_46Sequence_46Node_46size)
, bytes2word(0,0,0,0)
, useLabel(CT_v11024)
,};
Node FN_Data_46Sequence_46Sized_46Data_46Sequence_46Elem[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11024: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Data_46Sequence_46Sized_46Data_46Sequence_46Elem[] = {
  VAPTAG(useLabel(FN_Data_46Sequence_46Sized_46Data_46Sequence_46Elem))
, useLabel(F0_Data_46Sequence_46Sized_46Data_46Sequence_46Elem_46size)
, bytes2word(0,0,0,0)
, useLabel(CT_v11025)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46Elem[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11025: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Data_46Sequence_46Elem[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46Elem))
, useLabel(F0_Prelude_46Functor_46Data_46Sequence_46Elem_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v11026)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11026: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem[] = {
  VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem))
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldl1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldr1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46fold)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldl)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldMap)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem_46foldr)
, bytes2word(0,0,0,0)
, useLabel(CT_v11027)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11027: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem[] = {
  VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem))
, useLabel(CF_Prelude_46Functor_46Data_46Sequence_46Elem)
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46Elem)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46sequenceA)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46mapM)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46sequence)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46Elem_46traverse)
, bytes2word(0,0,0,0)
, useLabel(CT_v11028)
,};
Node FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewL[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11028: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewL[] = {
  VAPTAG(useLabel(FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewL))
, useLabel(F0_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewL_46typeOf1)
, bytes2word(1,0,0,1)
, useLabel(CT_v11029)
,};
Node FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewL[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I1,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11029: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewL[] = {
  CAPTAG(useLabel(FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewL),1)
, CAPTAG(useLabel(FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewL_46typeOf),1)
, bytes2word(0,0,0,0)
, useLabel(CT_v11030)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46ViewL[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11030: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Data_46Sequence_46ViewL[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46ViewL))
, useLabel(F0_Prelude_46Functor_46Data_46Sequence_46ViewL_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v11031)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11031: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL[] = {
  VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL))
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldl1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldr1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46fold)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldl)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldMap)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL_46foldr)
, bytes2word(0,0,0,0)
, useLabel(CT_v11032)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11032: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL[] = {
  VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL))
, useLabel(CF_Prelude_46Functor_46Data_46Sequence_46ViewL)
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewL)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46sequenceA)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46mapM)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46sequence)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewL_46traverse)
, bytes2word(0,0,0,0)
, useLabel(CT_v11033)
,};
Node FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewR[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11033: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewR[] = {
  VAPTAG(useLabel(FN_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewR))
, useLabel(F0_Data_46Typeable_46Typeable1_46Data_46Sequence_46ViewR_46typeOf1)
, bytes2word(1,0,0,1)
, useLabel(CT_v11034)
,};
Node FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewR[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_I3,HEAP_ARG)
, bytes2word(1,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_I1,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11034: (byte 0) */
  HW(1,1)
, 0
,};
Node F0_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewR[] = {
  CAPTAG(useLabel(FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewR),1)
, CAPTAG(useLabel(FN_Data_46Typeable_46Typeable_46Data_46Sequence_46ViewR_46typeOf),1)
, bytes2word(0,0,0,0)
, useLabel(CT_v11035)
,};
Node FN_Prelude_46Functor_46Data_46Sequence_46ViewR[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,1,0)
,	/* CT_v11035: (byte 0) */
  HW(1,0)
, 0
,};
Node CF_Prelude_46Functor_46Data_46Sequence_46ViewR[] = {
  VAPTAG(useLabel(FN_Prelude_46Functor_46Data_46Sequence_46ViewR))
, useLabel(F0_Prelude_46Functor_46Data_46Sequence_46ViewR_46fmap)
, bytes2word(0,0,0,0)
, useLabel(CT_v11036)
,};
Node FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11036: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR[] = {
  VAPTAG(useLabel(FN_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR))
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldl1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldr1)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46fold)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldl)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldMap)
, useLabel(F0_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR_46foldr)
, bytes2word(0,0,0,0)
, useLabel(CT_v11037)
,};
Node FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR[] = {
  bytes2word(NEEDHEAP_I32,PUSH_HEAP,HEAP_CVAL_N1,1)
, bytes2word(HEAP_CVAL_I3,HEAP_CVAL_I4,HEAP_CVAL_I5,HEAP_CVAL_P1)
, bytes2word(6,HEAP_CVAL_P1,7,HEAP_CVAL_P1)
, bytes2word(8,RETURN,ENDCODE,0)
, bytes2word(0,0,0,0)
, 0
, CONSTR(0,6,0)
,	/* CT_v11037: (byte 0) */
  HW(6,0)
, 0
,};
Node CF_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR[] = {
  VAPTAG(useLabel(FN_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR))
, useLabel(CF_Prelude_46Functor_46Data_46Sequence_46ViewR)
, useLabel(CF_Data_46Foldable_46Foldable_46Data_46Sequence_46ViewR)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46sequenceA)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46mapM)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46sequence)
, useLabel(F0_Data_46Traversable_46Traversable_46Data_46Sequence_46ViewR_46traverse)
,	/* ST_v10814: (byte 0) */
 	/* ST_v10905: (byte 3) */
  bytes2word(58,60,0,58)
,	/* ST_v10827: (byte 2) */
  bytes2word(62,0,68,97)
, bytes2word(116,97,46,83)
, bytes2word(101,113,117,101)
, bytes2word(110,99,101,58)
, bytes2word(32,78,111,32)
, bytes2word(109,97,116,99)
, bytes2word(104,32,105,110)
, bytes2word(32,112,97,116)
, bytes2word(116,101,114,110)
, bytes2word(32,101,120,112)
, bytes2word(114,101,115,115)
, bytes2word(105,111,110,32)
, bytes2word(97,116,32,54)
, bytes2word(55,56,58,50)
, bytes2word(56,45,54,55)
, bytes2word(56,58,51,49)
,	/* ST_v10918: (byte 2) */
  bytes2word(46,0,68,97)
, bytes2word(116,97,46,83)
, bytes2word(101,113,117,101)
, bytes2word(110,99,101,58)
, bytes2word(32,78,111,32)
, bytes2word(109,97,116,99)
, bytes2word(104,32,105,110)
, bytes2word(32,112,97,116)
, bytes2word(116,101,114,110)
, bytes2word(32,101,120,112)
, bytes2word(114,101,115,115)
, bytes2word(105,111,110,32)
, bytes2word(97,116,32,55)
, bytes2word(51,55,58,50)
, bytes2word(56,45,55,51)
, bytes2word(55,58,51,49)
,	/* ST_v10515: (byte 2) */
  bytes2word(46,0,68,97)
, bytes2word(116,97,46,83)
, bytes2word(101,113,117,101)
, bytes2word(110,99,101,58)
, bytes2word(32,80,97,116)
, bytes2word(116,101,114,110)
, bytes2word(32,109,97,116)
, bytes2word(99,104,32,102)
, bytes2word(97,105,108,117)
, bytes2word(114,101,32,105)
, bytes2word(110,32,102,117)
, bytes2word(110,99,116,105)
, bytes2word(111,110,32,97)
, bytes2word(116,32,52,50)
, bytes2word(52,58,49,45)
, bytes2word(52,51,51,58)
,	/* ST_v10420: (byte 4) */
  bytes2word(53,55,46,0)
, bytes2word(68,97,116,97)
, bytes2word(46,83,101,113)
, bytes2word(117,101,110,99)
, bytes2word(101,58,32,80)
, bytes2word(97,116,116,101)
, bytes2word(114,110,32,109)
, bytes2word(97,116,99,104)
, bytes2word(32,102,97,105)
, bytes2word(108,117,114,101)
, bytes2word(32,105,110,32)
, bytes2word(102,117,110,99)
, bytes2word(116,105,111,110)
, bytes2word(32,97,116,32)
, bytes2word(52,55,48,58)
, bytes2word(49,45,52,55)
, bytes2word(57,58,54,56)
,	/* ST_v10228: (byte 2) */
  bytes2word(46,0,68,97)
, bytes2word(116,97,46,83)
, bytes2word(101,113,117,101)
, bytes2word(110,99,101,58)
, bytes2word(32,80,97,116)
, bytes2word(116,101,114,110)
, bytes2word(32,109,97,116)
, bytes2word(99,104,32,102)
, bytes2word(97,105,108,117)
, bytes2word(114,101,32,105)
, bytes2word(110,32,102,117)
, bytes2word(110,99,116,105)
, bytes2word(111,110,32,97)
, bytes2word(116,32,53,49)
, bytes2word(54,58,49,45)
, bytes2word(53,50,53,58)
,	/* ST_v10292: (byte 4) */
  bytes2word(55,57,46,0)
, bytes2word(68,97,116,97)
, bytes2word(46,83,101,113)
, bytes2word(117,101,110,99)
, bytes2word(101,58,32,80)
, bytes2word(97,116,116,101)
, bytes2word(114,110,32,109)
, bytes2word(97,116,99,104)
, bytes2word(32,102,97,105)
, bytes2word(108,117,114,101)
, bytes2word(32,105,110,32)
, bytes2word(102,117,110,99)
, bytes2word(116,105,111,110)
, bytes2word(32,97,116,32)
, bytes2word(53,54,50,58)
, bytes2word(49,45,53,55)
, bytes2word(49,58,57,48)
,	/* ST_v10356: (byte 2) */
  bytes2word(46,0,68,97)
, bytes2word(116,97,46,83)
, bytes2word(101,113,117,101)
, bytes2word(110,99,101,58)
, bytes2word(32,80,97,116)
, bytes2word(116,101,114,110)
, bytes2word(32,109,97,116)
, bytes2word(99,104,32,102)
, bytes2word(97,105,108,117)
, bytes2word(114,101,32,105)
, bytes2word(110,32,102,117)
, bytes2word(110,99,116,105)
, bytes2word(111,110,32,97)
, bytes2word(116,32,54,48)
, bytes2word(56,58,49,45)
, bytes2word(54,49,55,58)
, bytes2word(49,48,49,46)
,	/* ST_v10105: (byte 1) */
  bytes2word(0,68,97,116)
, bytes2word(97,46,83,101)
, bytes2word(113,117,101,110)
, bytes2word(99,101,58,32)
, bytes2word(80,97,116,116)
, bytes2word(101,114,110,32)
, bytes2word(109,97,116,99)
, bytes2word(104,32,102,97)
, bytes2word(105,108,117,114)
, bytes2word(101,32,105,110)
, bytes2word(32,102,117,110)
, bytes2word(99,116,105,111)
, bytes2word(110,32,97,116)
, bytes2word(32,55,57,49)
, bytes2word(58,49,45,55)
, bytes2word(57,52,58,52)
,	/* ST_v10093: (byte 3) */
  bytes2word(53,46,0,68)
, bytes2word(97,116,97,46)
, bytes2word(83,101,113,117)
, bytes2word(101,110,99,101)
, bytes2word(58,32,80,97)
, bytes2word(116,116,101,114)
, bytes2word(110,32,109,97)
, bytes2word(116,99,104,32)
, bytes2word(102,97,105,108)
, bytes2word(117,114,101,32)
, bytes2word(105,110,32,102)
, bytes2word(117,110,99,116)
, bytes2word(105,111,110,32)
, bytes2word(97,116,32,56)
, bytes2word(48,52,58,49)
, bytes2word(45,56,49,50)
, bytes2word(58,51,48,46)
,	/* ST_v10074: (byte 1) */
  bytes2word(0,68,97,116)
, bytes2word(97,46,83,101)
, bytes2word(113,117,101,110)
, bytes2word(99,101,58,32)
, bytes2word(80,97,116,116)
, bytes2word(101,114,110,32)
, bytes2word(109,97,116,99)
, bytes2word(104,32,102,97)
, bytes2word(105,108,117,114)
, bytes2word(101,32,105,110)
, bytes2word(32,102,117,110)
, bytes2word(99,116,105,111)
, bytes2word(110,32,97,116)
, bytes2word(32,56,49,55)
, bytes2word(58,49,45,56)
, bytes2word(50,54,58,50)
,	/* ST_v10055: (byte 3) */
  bytes2word(57,46,0,68)
, bytes2word(97,116,97,46)
, bytes2word(83,101,113,117)
, bytes2word(101,110,99,101)
, bytes2word(58,32,80,97)
, bytes2word(116,116,101,114)
, bytes2word(110,32,109,97)
, bytes2word(116,99,104,32)
, bytes2word(102,97,105,108)
, bytes2word(117,114,101,32)
, bytes2word(105,110,32,102)
, bytes2word(117,110,99,116)
, bytes2word(105,111,110,32)
, bytes2word(97,116,32,56)
, bytes2word(51,49,58,49)
, bytes2word(45,56,52,57)
, bytes2word(58,51,48,46)
,	/* ST_v10025: (byte 1) */
  bytes2word(0,68,97,116)
, bytes2word(97,46,83,101)
, bytes2word(113,117,101,110)
, bytes2word(99,101,58,32)
, bytes2word(80,97,116,116)
, bytes2word(101,114,110,32)
, bytes2word(109,97,116,99)
, bytes2word(104,32,102,97)
, bytes2word(105,108,117,114)
, bytes2word(101,32,105,110)
, bytes2word(32,102,117,110)
, bytes2word(99,116,105,111)
, bytes2word(110,32,97,116)
, bytes2word(32,56,53,55)
, bytes2word(58,49,45,56)
, bytes2word(53,57,58,50)
,	/* ST_v10016: (byte 3) */
  bytes2word(52,46,0,68)
, bytes2word(97,116,97,46)
, bytes2word(83,101,113,117)
, bytes2word(101,110,99,101)
, bytes2word(58,32,80,97)
, bytes2word(116,116,101,114)
, bytes2word(110,32,109,97)
, bytes2word(116,99,104,32)
, bytes2word(102,97,105,108)
, bytes2word(117,114,101,32)
, bytes2word(105,110,32,102)
, bytes2word(117,110,99,116)
, bytes2word(105,111,110,32)
, bytes2word(97,116,32,56)
, bytes2word(54,53,58,49)
, bytes2word(45,56,55,50)
, bytes2word(58,51,48,46)
,	/* ST_v10000: (byte 1) */
  bytes2word(0,68,97,116)
, bytes2word(97,46,83,101)
, bytes2word(113,117,101,110)
, bytes2word(99,101,58,32)
, bytes2word(80,97,116,116)
, bytes2word(101,114,110,32)
, bytes2word(109,97,116,99)
, bytes2word(104,32,102,97)
, bytes2word(105,108,117,114)
, bytes2word(101,32,105,110)
, bytes2word(32,102,117,110)
, bytes2word(99,116,105,111)
, bytes2word(110,32,97,116)
, bytes2word(32,56,55,55)
, bytes2word(58,49,45,56)
, bytes2word(56,54,58,50)
,	/* ST_v9981: (byte 3) */
  bytes2word(57,46,0,68)
, bytes2word(97,116,97,46)
, bytes2word(83,101,113,117)
, bytes2word(101,110,99,101)
, bytes2word(58,32,80,97)
, bytes2word(116,116,101,114)
, bytes2word(110,32,109,97)
, bytes2word(116,99,104,32)
, bytes2word(102,97,105,108)
, bytes2word(117,114,101,32)
, bytes2word(105,110,32,102)
, bytes2word(117,110,99,116)
, bytes2word(105,111,110,32)
, bytes2word(97,116,32,56)
, bytes2word(57,49,58,49)
, bytes2word(45,57,48,57)
, bytes2word(58,51,48,46)
,	/* ST_v9944: (byte 1) */
  bytes2word(0,68,97,116)
, bytes2word(97,46,83,101)
, bytes2word(113,117,101,110)
, bytes2word(99,101,58,32)
, bytes2word(80,97,116,116)
, bytes2word(101,114,110,32)
, bytes2word(109,97,116,99)
, bytes2word(104,32,102,97)
, bytes2word(105,108,117,114)
, bytes2word(101,32,105,110)
, bytes2word(32,102,117,110)
, bytes2word(99,116,105,111)
, bytes2word(110,32,97,116)
, bytes2word(32,57,50,56)
, bytes2word(58,49,45,57)
, bytes2word(51,50,58,51)
,	/* ST_v9917: (byte 3) */
  bytes2word(54,46,0,68)
, bytes2word(97,116,97,46)
, bytes2word(83,101,113,117)
, bytes2word(101,110,99,101)
, bytes2word(58,32,80,97)
, bytes2word(116,116,101,114)
, bytes2word(110,32,109,97)
, bytes2word(116,99,104,32)
, bytes2word(102,97,105,108)
, bytes2word(117,114,101,32)
, bytes2word(105,110,32,102)
, bytes2word(117,110,99,116)
, bytes2word(105,111,110,32)
, bytes2word(97,116,32,57)
, bytes2word(52,50,58,49)
, bytes2word(45,57,53,52)
, bytes2word(58,50,53,46)
,	/* ST_v9819: (byte 1) */
  bytes2word(0,68,97,116)
, bytes2word(97,46,83,101)
, bytes2word(113,117,101,110)
, bytes2word(99,101,58,32)
, bytes2word(80,97,116,116)
, bytes2word(101,114,110,32)
, bytes2word(109,97,116,99)
, bytes2word(104,32,102,97)
, bytes2word(105,108,117,114)
, bytes2word(101,32,105,110)
, bytes2word(32,102,117,110)
, bytes2word(99,116,105,111)
, bytes2word(110,32,97,116)
, bytes2word(32,57,55,53)
, bytes2word(58,49,45,57)
, bytes2word(56,52,58,50)
,	/* ST_v9800: (byte 3) */
  bytes2word(57,46,0,68)
, bytes2word(97,116,97,46)
, bytes2word(83,101,113,117)
, bytes2word(101,110,99,101)
, bytes2word(58,32,80,97)
, bytes2word(116,116,101,114)
, bytes2word(110,32,109,97)
, bytes2word(116,99,104,32)
, bytes2word(102,97,105,108)
, bytes2word(117,114,101,32)
, bytes2word(105,110,32,102)
, bytes2word(117,110,99,116)
, bytes2word(105,111,110,32)
, bytes2word(97,116,32,57)
, bytes2word(56,57,58,49)
, bytes2word(45,49,48,48)
, bytes2word(55,58,51,48)
,	/* ST_v10812: (byte 2) */
  bytes2word(46,0,69,109)
, bytes2word(112,116,121,76)
,	/* ST_v10903: (byte 1) */
  bytes2word(0,69,109,112)
,	/* ST_v10807: (byte 4) */
  bytes2word(116,121,82,0)
, bytes2word(78,111,32,100)
, bytes2word(101,102,97,117)
, bytes2word(108,116,32,100)
, bytes2word(101,102,105,110)
, bytes2word(105,116,105,111)
, bytes2word(110,32,102,111)
, bytes2word(114,32,99,108)
, bytes2word(97,115,115,32)
, bytes2word(109,101,116,104)
, bytes2word(111,100,32,115)
,	/* ST_v10665: (byte 4) */
  bytes2word(105,122,101,0)
,	/* ST_v10186: (byte 4) */
  bytes2word(83,101,113,0)
, bytes2word(86,105,101,119)
,	/* ST_v10146: (byte 2) */
  bytes2word(76,0,86,105)
,	/* ST_v10018: (byte 4) */
  bytes2word(101,119,82,0)
, bytes2word(97,100,106,117)
, bytes2word(115,116,84,114)
, bytes2word(101,101,32,111)
, bytes2word(102,32,101,109)
, bytes2word(112,116,121,32)
, bytes2word(116,114,101,101)
,	/* ST_v10633: (byte 1) */
  bytes2word(0,102,111,108)
, bytes2word(100,108,49,58)
, bytes2word(32,101,109,112)
, bytes2word(116,121,32,115)
, bytes2word(101,113,117,101)
,	/* ST_v10168: (byte 4) */
  bytes2word(110,99,101,0)
, bytes2word(102,111,108,100)
, bytes2word(108,49,58,32)
, bytes2word(101,109,112,116)
, bytes2word(121,32,118,105)
,	/* ST_v10641: (byte 3) */
  bytes2word(101,119,0,102)
, bytes2word(111,108,100,114)
, bytes2word(49,58,32,101)
, bytes2word(109,112,116,121)
, bytes2word(32,115,101,113)
, bytes2word(117,101,110,99)
,	/* ST_v10128: (byte 2) */
  bytes2word(101,0,102,111)
, bytes2word(108,100,114,49)
, bytes2word(58,32,101,109)
, bytes2word(112,116,121,32)
, bytes2word(118,105,101,119)
,	/* ST_v10772: (byte 1) */
  bytes2word(0,102,114,111)
, bytes2word(109,76,105,115)
,	/* ST_v10107: (byte 3) */
  bytes2word(116,32,0,105)
, bytes2word(110,100,101,120)
, bytes2word(32,111,117,116)
, bytes2word(32,111,102,32)
, bytes2word(98,111,117,110)
,	/* ST_v10095: (byte 3) */
  bytes2word(100,115,0,108)
, bytes2word(111,111,107,117)
, bytes2word(112,84,114,101)
, bytes2word(101,32,111,102)
, bytes2word(32,101,109,112)
, bytes2word(116,121,32,116)
,	/* ST_v10764: (byte 4) */
  bytes2word(114,101,101,0)
, bytes2word(112,97,116,116)
, bytes2word(101,114,110,45)
, bytes2word(109,97,116,99)
, bytes2word(104,32,102,97)
, bytes2word(105,108,117,114)
, bytes2word(101,32,105,110)
, bytes2word(32,100,111,32)
, bytes2word(101,120,112,114)
, bytes2word(101,115,115,105)
,	/* ST_v9919: (byte 3) */
  bytes2word(111,110,0,115)
, bytes2word(112,108,105,116)
, bytes2word(84,114,101,101)
, bytes2word(32,111,102,32)
, bytes2word(101,109,112,116)
, bytes2word(121,32,116,114)
, bytes2word(101,101,0,0)
,};
