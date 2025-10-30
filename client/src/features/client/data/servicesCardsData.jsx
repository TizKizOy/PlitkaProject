import { CiGrid41, CiDroplet, CiMaximize2 } from "react-icons/ci";
import { PiPlantThin } from "react-icons/pi";

const serviceCardsData = [
  {
    id: 1,
    icon: <CiGrid41 />,
    title: "укладка плитки дорожные работы",
    text: ["тротуарная плитка", "грунтовые дороги"],
  },
  {
    id: 2,
    icon: <CiMaximize2 />,
    title: "возведение фундамента",
    text: ["строительство фундамента ", "возведение построек"],
  },
  {
    id: 3,
    icon: <PiPlantThin />,
    title: "посев газона|установка забора",
    text: ["установка заборов", "посев газона"],
  },
  {
    id: 4,
    icon: <CiDroplet />,
    title: "коммуникации водоотведение",
    text: ["проведение коммуникаций", "систем водоотведения"],
  },
];

export default serviceCardsData;
