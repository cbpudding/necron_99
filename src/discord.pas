unit discord;

{$link orca/lib/libdiscord.a}
{$linklib libc}
{$linklib libcurl}
{$linklib libpthread}
{$packrecords C}

interface

uses ctypes;

type
Snowflake = QWord;
PDiscordAllowedMentions = ^ DiscordAllowedMentions;
DiscordAllowedMentions = record
    { ... }
end;
PDiscordAttachment = ^ DiscordAttachment;
DiscordAttachment = record
    { ... }
end;
PDiscordChannel = ^ DiscordChannel;
DiscordChannel = record
    { ... }
end;
PDiscordChannelMention = ^ DiscordChannelMention;
DiscordChannelMention = record
    { ... }
end;
PDiscordClient = ^ DiscordClient;
DiscordClient = record
    { The inner machinations of my mind are an enigma. }
end;
PDiscordComponent = ^ DiscordComponent;
DiscordComponent = record
    { ... }
end;
PDiscordEmbed = ^ DiscordEmbed;
DiscordEmbed = record
    { ... }
end;
PDiscordMessageReference = ^ DiscordMessageReference;
DiscordMessageReference = record
    { ... }
end;
PDiscordReaction = ^ DiscordReaction;
DiscordReaction = record
    { ... }
end;
PDiscordCreateMessageParams = ^ DiscordCreateMessageParams;
DiscordCreateMessageParams = record
    content: PChar;
    tts: boolean;
    embeds: ^PDiscordEmbed;
    embed: PDiscordEmbed;
    allowed_mentions: PDiscordAllowedMentions;
    message_reference: PDiscordMessageReference;
    components: ^PDiscordComponent;
    sticker_ids: ^PQWord;
    attachments: ^PDiscordAttachment;
end;
DiscordUserPremiumTypes = (
    USER_NITRO_CLASSIC = 0,
    USER_NITRO = 1
);
DiscordUserFlags = (
    USER_DISCORD_EMPLOYEE = 1,
    USER_PARTNERED_SERVER_OWNER = 2,
    USER_HYPESQUAD_EVENTS = 4,
    USER_BUG_HUNTER_LEVEL_1 = 8,
    USER_HOUSE_BRAVERY = 32,
    USER_HOUSE_BRILLIANCE = 64,
    USER_HOUSE_BALANCE = 128,
    USER_EARLY_SUPPORTER = 256,
    USER_TEAM_USER = 512,
    USER_SYSTEM = 4096,
    USER_BUG_HUNTER_LEVEL_2 = 16384,
    USER_VERIFIED_BOT = 65536,
    USER_EARLY_VERIFIED_BOT_DEVELOPER = 131072
);
PDiscordUser = ^ DiscordUser;
DiscordUser = record
    id: Snowflake;
    username: PChar;
    discriminator: PChar;
    avatar: PChar;
    bot: boolean;
    system: boolean;
    mfa_enabled: boolean;
    locale: PChar;
    verified: boolean;
    email: PChar;
    flags: DiscordUserFlags;
    banner: PChar;
    premium_type: DiscordUserPremiumTypes;
    public_flags: DiscordUserFlags;
end;
PDiscordGuildMember = ^ DiscordGuildMember;
DiscordGuildMember = record
    user: PDiscordUser;
    nick: PChar;
    roles: PQWord; // **
    joined_at: QWord; // Unix Timestamp
    premium_since: QWord; // Ditto
    deaf: boolean;
    mute: boolean;
    pending: boolean;
    permissions: PChar;
end;
PDiscordMessageActivity = ^ DiscordMessageActivity;
DiscordMessageActivity = record
    { ... }
end;
PDiscordMessageApplication = ^ DiscordMessageApplication;
DiscordMessageApplication = record
    { ... }
end;
PDiscordMessageInteraction = ^ DiscordMessageInteraction;
DiscordMessageInteraction = record
    { ... }
end;
PDiscordMessageSticker = ^ DiscordMessageSticker;
DiscordMessageSticker = record
    { ... }
end;
DiscordMessageTypes = (
    MESSAGE_DEFAULT = 0,
    MESSAGE_RECIPIENT_ADD = 1,
    MESSAGE_RECIPIENT_REMOVE = 2,
    MESSAGE_CALL = 3,
    MESSAGE_CHANNEL_NAME_CHANGE = 4,
    MESSAGE_CHANNEL_ICON_CHANGE = 5,
    MESSAGE_CHANNEL_PINNED_MESSAGE = 6,
    MESSAGE_GUILD_MEMBER_JOIN = 7,
    MESSAGE_USER_PREMIUM_GUILD_SUBSCRIPTION = 8,
    MESSAGE_USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_1 = 9,
    MESSAGE_USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_2 = 10,
    MESSAGE_USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_3 = 11,
    MESSAGE_CHANNEL_FOLLOW_ADD = 12,
    MESSAGE_GUILD_DISCOVERY_DISQUALIFIED = 14,
    MESSAGE_GUILD_DISCOVERY_REQUALIFIED = 15,
    MESSAGE_REPLY = 19,
    MESSAGE_APPLICATION_COMMAND = 20
);
DiscordMessageFlags = (
    MESSAGE_CROSSPOSTED = 1,
    MESSAGE_IS_CROSSPOST = 2,
    MESSAGE_SUPRESS_EMBEDS = 4,
    MESSAGE_SOURCE_MESSAGE_DELETED = 8,
    MESSAGE_URGENT = 16
);
PDiscordMessage = ^ DiscordMessage;
DiscordMessage = record
    id: Snowflake;
    channel_id: Snowflake;
    guild_id: Snowflake;
    author: PDiscordUser;
    member: PDiscordGuildMember;
    content: PChar;
    timestamp: QWord;
    edited_timestamp: QWord;
    tts: boolean;
    mention_everyone: boolean;
    mentions: ^PDiscordUser;
    mention_roles: PQWord; // Technically a pointer to a pointer
    mention_channels: PDiscordChannelMention; // Ditto
    embeds: PDiscordEmbed; // Ack
    reactions: PDiscordReaction; // End my suffering
    nonce: PChar;
    pinned: boolean;
    webhook_id: Snowflake;
    message_type: DiscordMessageTypes;
    activity: PDiscordMessageActivity;
    application: PDiscordMessageApplication; // **
    message_reference: PDiscordMessageReference;
    flags: DiscordMessageFlags;
    referenced_message: PDiscordMessage;
    interaction: PDiscordMessageInteraction;
    thread: PDiscordChannel;
    components: PDiscordComponent; // **
    sticker_items: PDiscordMessageSticker; // **
    stickers: PDiscordMessageSticker; // **
end;
ORCAcode = integer;

procedure discord_cleanup(client: PDiscordClient); cdecl; external;
function discord_create_message(client: PDiscordClient; channel_id: Snowflake; params: PDiscordCreateMessageParams; ret: PDiscordMessage): ORCAcode; cdecl; external;
function discord_init(token: PChar): PDiscordClient; cdecl; external;
procedure discord_message_cleanup(msg: PDiscordMessage); cdecl; external;
procedure discord_run(client: PDiscordClient); cdecl; external;
procedure discord_set_on_message_create(client: PDiscordClient; callback: Pointer); cdecl; external;

implementation

end.