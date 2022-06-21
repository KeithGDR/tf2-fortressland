#if defined _hud_included
  #endinput
#endif

methodmap Hud < Handle {
	public Hud() {
		return view_as<Hud>(CreateHudSynchronizer());
	}
	
	property Handle index { 
		public get() {
			return view_as<Handle>(this);
		}
	}
	
	public void Clear(int client) {
		ClearSyncHud(client, this.index);
	}
	
	public void ClearAll() {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && !IsFakeClient(i)) {
				ClearSyncHud(i, this.index);
			}
		}
	}
	
	public void SetParams(float x = -1.0, float y = -1.0, float holdTime = 2.0, int r = 255, int g = 255, int b = 255, int a = 255, int effect = 0, float fxTime = 6.0, float fadeIn = 0.1, float fadeOut = 0.2) {
		SetHudTextParams(x, y, holdTime, r, g, b, a, effect, fxTime, fadeIn, fadeOut);
	}
	
	public void SetParamsEx(float x = -1.0, float y = -1.0, float holdTime = 2.0, int color1[4] = {255, 255, 255, 255}, int color2[4] = {255, 255, 255, 255}, int effect = 0, float fxTime = 6.0, float fadeIn = 0.1, float fadeOut = 0.2) {
		SetHudTextParamsEx(x, y, holdTime, color1, color2, effect, fxTime, fadeIn, fadeOut);
	}
	
	public void Send(int client, const char[] format, any ...) {
		int size = strlen(format) + 255;
		char[] sBuffer = new char[size];
		VFormat(sBuffer, size, format, 4);
		ShowSyncHudText(client, this.index, sBuffer);
	}
	
	public void SendToAll(const char[] format, any ...) {
		int size = strlen(format) + 255;
		char[] sBuffer = new char[size];
		VFormat(sBuffer, size, format, 3);
		
		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && !IsFakeClient(i)) {
				ShowSyncHudText(i, this.index, sBuffer);
			}
		}
	}
}