import { atom } from "recoil";
import { SelectType } from "../types/types";
export const Lang = atom<Object>({
  key: "lang",
  default: {},
});

export const Regions = atom<SelectType[]>({
  key: "regions",
  default: [],
});
