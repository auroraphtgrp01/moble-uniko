export const getAvatarPath = (avatarId: string | null): string => {
  if (!avatarId) {
    return '/assets/avatars/default.png'; 
  }
  
  return `/assets/avatars/${avatarId}.png`;
}; 