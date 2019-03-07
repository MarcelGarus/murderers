// Error codes.
export const CODE_BAD_REQUEST: number = 400;
export const CODE_USER_NOT_FOUND: number = 404;
export const CODE_USER_CORRUPT: number = 500;
export const CODE_AUTHENTIFICATION_FAILED: number = 403;
export const CODE_NO_PRIVILEGES: number = 403;
export const CODE_GAME_NOT_FOUND: number = 404;
export const CODE_GAME_CORRUPT: number = 500;
export const CODE_PLAYER_NOT_FOUND: number = 404;
export const CODE_PLAYER_CORRUPT: number = 500;
export const CODE_ILLEGAL_STATE: number = 500;

// Error texts.
export const TEXT_USER_NOT_FOUND: string = 'User not found.';
export const TEXT_USER_CORRUPT: string = 'User corrupt.';
export const TEXT_AUTHENTIFICATION_FAILED: string = 'Authentification failed.';
export const TEXT_NO_PRIVILEGES: string = 'No privileges.';
export const TEXT_GAME_NOT_FOUND: string = 'Game not found.';
export const TEXT_GAME_CORRUPT: string = 'Game corrupt.';
export const TEXT_PLAYER_NOT_FOUND: string = 'Player not found.';
export const TEXT_PLAYER_CORRUPT: string = 'Player corrupt.';
export const TEXT_ILLEGAL_STATE: string = 'Illegal state.';

// Constants for creating users.
export const USER_ID_CHARS: string = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
export const USER_ID_LENGTH: number = 10;

// Constants for creating games.
export const GAME_CODE_CHARS: string = 'abcdefghijklmnopqrstuvwxyz0123456789';
export const GAME_CODE_LENGTH: number = 5;
