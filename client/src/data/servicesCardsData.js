import WorkPlitka from "../image/workPlitka.png";
import Grass from "../image/grass.png";
import Sewage from "../image/sewage.png";
import Construction from "../image/construction.png";

const serviceCardsData = [
  {
    id: 1,
    icon: WorkPlitka,
    title: "укладка плитки дорожные работы",
    text: ["грунтовые дороги", "тротуарная плитка"],
  },
  {
    id: 2,
    icon: Construction,
    title: "возведение фундамента",
    text: ["строительство фундамента ", "возведение построек"],
  },
  {
    id: 3,
    icon: Grass,
    title: "посев газона|установка забора",
    text: ["установка заборов", "посев газона"],
  },
  {
    id: 4,
    icon: Sewage,
    title: "коммуникации водоотведение",
    text: ["проведение коммуникаций", "систем водоотведения"],
  },
];

export default serviceCardsData;
