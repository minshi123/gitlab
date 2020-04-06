import { LOADING, LOADED } from '../constants';

export const isLoadingContent = ({ status }) => status === LOADING;
export const isContentLoaded = ({ status }) => status === LOADED;
export const isSavingChanges = () => false; // TODO: Implement
export const contentChanged = () => true; // TODO: Implement
