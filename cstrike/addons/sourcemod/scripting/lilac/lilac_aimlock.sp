/*
	Little Anti-Cheat
	Copyright (C) 2018-2023 J_Tanzanite

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

static bool aimlock_skip_player(int client)
{
	if (!is_player_valid(client)
		|| IsFakeClient(client)
		|| !IsPlayerAlive(client)
		|| GetClientTeam(client) < 2
		|| GetGameTime() - playerinfo_time_teleported[client] < 2.0
		|| skip_due_to_loss(client)
		|| playerinfo_banned_flags[client][CHEAT_AIMLOCK])
		return true;

	if (icvar[CVAR_AIMLOCK_LIGHT] == 1 && lilac_is_player_in_aimlock_que(client) == false)
		return true;

	return false;
}

static bool aimlock_skip_target(int client, int target)
{
	return (client == target
		|| !is_player_valid(target)
		|| GetClientTeam(client) == GetClientTeam(target)
		|| !IsPlayerAlive(target)
		|| GetClientTeam(target) < 2
		|| GetGameTime() - playerinfo_time_teleported[target] < 2.0);
}

public Action timer_check_aimlock(Handle timer)
{
	float pos[3], pos2[3];
	int players_processed = 0;
	bool detected_aimlock[MAXPLAYERS + 1];

	if (!icvar[CVAR_ENABLE] || !icvar[CVAR_AIMLOCK])
		return Plugin_Continue;

	for (int client = 1; client <= MaxClients; client++) {
		detected_aimlock[client] = false;

		if (icvar[CVAR_AIMLOCK_LIGHT] == 1 && players_processed >= 5)
			continue;

		if (aimlock_skip_player(client))
			continue;

		GetClientEyePosition(client, pos);

		players_processed++;

		bool process = true;
		for (int target = 1; process && target <= MaxClients; target++) {
			if (aimlock_skip_target(client, target))
				continue;

			GetClientEyePosition(target, pos2);

			if (GetVectorDistance(pos, pos2) < 300.0) {
				detected_aimlock[client] = false;
				process = false;
				continue;
			}

			if (detected_aimlock[client])
				continue;

			if (is_aimlocking(client, pos, pos2))
				detected_aimlock[client] = true;
		}
	}

	for (int i = 1; i <= MaxClients; i++) {
		if (detected_aimlock[i])
			lilac_detected_aimlock(i);
	}

	return Plugin_Continue;
}

static bool is_aimlocking(int client, float pos[3], float pos2[3])
{
	float ideal[3], lang[3], ang[3];
	float laimdist, aimdist;
	int lock = 0;
	int ind;

	aim_at_point(pos, pos2, ideal);

	ind = playerinfo_index[client];
	for (int i = 0; i < time_to_ticks(0.5 + 0.1); i++) {
		if (ind < 0)
			ind += CMD_LENGTH;

		if (GetGameTime() - playerinfo_time_usercmd[client][ind] < 0.5 + 0.1) {
			get_player_log_angles(client, ind, false, ang);
			laimdist = angle_delta(ang, ideal);

			if (i) {
				if (aimdist < 5.0)
					lock++;
				else
					lock = 0;

				if (aimdist < laimdist * 0.1
					&& angle_delta(ang, lang) > 20.0
					&& lock > time_to_ticks(0.1))
					return true;
			}

			lang = ang;
			aimdist = laimdist;
		}

		ind--;
	}

	return false;
}

static void lilac_detected_aimlock(int client)
{
	if (playerinfo_banned_flags[client][CHEAT_AIMLOCK])
		return;

	if (GetGameTime() - playerinfo_time_aimlock[client] < 180.0)
		playerinfo_aimlock_sus[client]++;
	else
		playerinfo_aimlock_sus[client] = 1;

	playerinfo_time_aimlock[client] = GetGameTime();

	if (playerinfo_aimlock_sus[client] < 2)
		return;

	playerinfo_aimlock_sus[client] = 0;

	if (lilac_forward_allow_cheat_detection(client, CHEAT_AIMLOCK) == false)
		return;

	CreateTimer(600.0, timer_decrement_aimlock, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

	lilac_forward_client_cheat(client, CHEAT_AIMLOCK);

	if (++playerinfo_aimlock[client] < 2)
		return;

	if (icvar[CVAR_CHEAT_WARN])
		lilac_warn_admins(client, CHEAT_AIMLOCK, playerinfo_aimlock[client]);

	if (icvar[CVAR_LOG]) {
		lilac_log_setup_client(client);
		Format(line_buffer, sizeof(line_buffer),
			"%s is suspected of using an aimlock (Detection: %d).",
			line_buffer, playerinfo_aimlock[client]);

		lilac_log(true);

		if (icvar[CVAR_LOG_EXTRA] == 2)
			lilac_log_extra(client);
	}
	database_log(client, "aimlock", playerinfo_aimlock[client]);

	if (playerinfo_aimlock[client] >= icvar[CVAR_AIMLOCK]
		&& icvar[CVAR_AIMLOCK] >= AIMLOCK_BAN_MIN) {
		playerinfo_banned_flags[client][CHEAT_AIMLOCK] = true;

		if (icvar[CVAR_LOG]) {
			lilac_log_setup_client(client);
			Format(line_buffer, sizeof(line_buffer),
				"%s was banned for Aimlock.", line_buffer);

			lilac_log(true);

			if (icvar[CVAR_LOG_EXTRA])
				lilac_log_extra(client);
		}
		database_log(client, "aimlock", DATABASE_BAN);

		lilac_ban_client(client, CHEAT_AIMLOCK);
	}
}

void lilac_aimlock_light_test(int client)
{
	int ind;
	float lastang[3], ang[3];

	if (GetGameTime() - playerinfo_time_teleported[client] < 3.0)
		return;

	ind = playerinfo_index[client];
	for (int i = 0; i < time_to_ticks(0.5); i++) {
		if (ind < 0)
			ind += CMD_LENGTH;

		get_player_log_angles(client, ind, false, ang);

		if (i) {
			if (angle_delta(lastang, ang) > 20.0) {
				playerinfo_time_process_aimlock[client] = GetGameTime() + 200.0;
				return;
			}
		}

		lastang = ang;
		ind--;
	}
}

static bool lilac_is_player_in_aimlock_que(int client)
{
	return (GetGameTime() < playerinfo_time_process_aimlock[client]
		|| playerinfo_aimlock[client]
		|| lilac_aimbot_get_client_detections(client) > 1
		|| GetClientTime(client) < 240.0
		|| (GetGameTime() - playerinfo_time_aimlock[client] < 180.0
			&& playerinfo_time_aimlock[client] > 1.0));
}

public Action timer_decrement_aimlock(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (!is_player_valid(client))
		return Plugin_Continue;

	if (playerinfo_aimlock[client] > 0)
		playerinfo_aimlock[client]--;

	return Plugin_Continue;
}
