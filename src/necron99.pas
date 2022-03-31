program necron99;

uses classes, Contnrs, discord, StrUtils, sysutils;

var
    client: PDiscordClient;
    token: AnsiString;
    token_file: Text;

{ Utilities }

function command_num(cmd: AnsiString): integer;
const
    commands: array of AnsiString = ('info', 'calc', 'suggest', 'xkcd', 'starwars', 'help', 'invite', 'fortune');
var
    i: integer;
begin
    for i := 0 to High(commands) do
        if (CompareText(cmd, commands[i]) = 0) then
            Exit(i);
    command_num := -1;
end;

function rpn_is_op(symbol: char): boolean;
const
    ops: array of char = ('+', '-', '*', '/');
var
    op: char;
begin
    for op in ops do
        if op = symbol then
            exit(true);
    rpn_is_op := false;
end;

{
    Return values:
    0: Nothing went wrong
    1: Not enough items
    2: Invalid operator
    3: Invalid first argument
    4: Invalid second argument
    5: Division by zero
}
function rpn_calc(stack: TStack): integer;
var
    code: integer;
    op: char;
    result: ^AnsiString;
    tmp: PChar;
    x, y: integer;
begin
    if stack.count < 3 then
        exit(1);
    op := PChar(stack.pop())^;
    if not rpn_is_op(op) then
        exit(2);
    tmp := PChar(stack.pop());
    if (StrLen(tmp) = 1) and rpn_is_op(tmp^) then begin
        stack.push(tmp);
        code := rpn_calc(stack);
        if code <> 0 then
            exit(code);
        tmp := PChar(stack.pop());
    end;
    val(tmp, y, code);
    if code <> 0 then
        exit(3);
    tmp := PChar(stack.pop());
    if (StrLen(tmp) = 1) and rpn_is_op(tmp^) then begin
        stack.push(tmp);
        code := rpn_calc(stack);
        if code <> 0 then
            exit(code);
        tmp := PChar(stack.pop());
    end;
    val(tmp, x, code);
    if code <> 0 then
        exit(4);
    new(result);
    case op of
        '+': str(x + y, result^);
        '-': str(x - y, result^);
        '*': str(x * y, result^);
        '/': if y = 0 then
                exit(5)
            else
                str(x div y, result^);
    else
        exit(2);
    end;
    stack.push(PChar(result^));
    rpn_calc := 0;
end;

procedure send_message(client: PDiscordClient; channel_id: Snowflake; content: AnsiString);
var
    msg: DiscordCreateMessageParams;
    ret: DiscordMessage;
begin
    msg.content := PChar(content);
    msg.tts := false;
    msg.embeds := nil;
    msg.embed := nil;
    msg.allowed_mentions := nil;
    msg.message_reference := nil;
    msg.components := nil;
    msg.sticker_ids := nil;
    msg.attachments := nil;
    discord_create_message(client, channel_id, addr(msg), addr(ret));
    discord_message_cleanup(addr(ret));
end;

{ Commands }

procedure calc_command(client: PDiscordClient; msg: PDiscordMessage; args: array of AnsiString);
var
    i: integer;
    stack: TStack;
    tmp: AnsiString;
begin
    if Length(args) > 4 then begin
        stack := TStack.create;
        for i := 2 to High(args) do
            stack.push(PChar(args[i]));
        i := rpn_calc(stack);
        if i = 0 then
            send_message(client, msg^.channel_id, AnsiString(stack.pop()))
        else begin
            { TODO: Display errors to the user }
            str(i, tmp);
            writeln('calc_command: Error ' + tmp + ': ' + msg^.content);
            send_message(client, msg^.channel_id, 'An error occured. Please check your equation and make sure it''s formatted correctly(I only understand reverse polish notation!)');
        end;
        stack.destroy();
    end;
end;

procedure fortune_command(client: PDiscordClient; msg: PDiscordMessage);
begin
    { ... }
end;

procedure help_command(client: PDiscordClient; msg: PDiscordMessage);
const
    newline = #10;
begin
    send_message(client, msg^.channel_id,
        'calc - A reverse polish notation calculator(Example: calc 2 2 +)' + newline +
        'help - Displays a list of commands the bot supports' + newline +
        'info - Displays a short description about the bot' + newline +
        'invite - Invite the bot to your Discord server' + newline +
        'suggest - Suggest a feature to add to the bot'
    );
end;

procedure info_command(client: PDiscordClient; msg: PDiscordMessage);
begin
    send_message(client, msg^.channel_id, 'Necron 99 is a Discord bot written by Breadpudding#9078 in Pascal for the sole purpose of writing and designing a Discord bot as if it were the 1970s. Of course, I''m assuming Discord bots existed in the 1970s, which they didn''t, but if they did, this is probably what one would look like.');
end;

procedure invite_command(client: PDiscordClient; msg: PDiscordMessage);
begin
    send_message(client, msg^.channel_id, 'https://discord.com/api/oauth2/authorize?client_id=942991629202112603&permissions=3072&scope=bot');
end;

procedure starwars_command(client: PDiscordClient; msg: PDiscordMessage; args: array of AnsiString);
begin
    // ...
end;

procedure suggest_command(client: PDiscordClient; msg: PDiscordMessage; args: array of AnsiString);
var
    author: PDiscordUser;
    i: integer;
    suggestion: AnsiString;
begin
    if Length(args) > 2 then begin
        author := msg^.author;
        suggestion := '';
        for i := 2 to High(args) do
            suggestion += args[i] + ' ';
        writeln('Suggestion from ' + author^.username + '#' + author^.discriminator + ': ' + suggestion);
        send_message(client, msg^.channel_id, 'Your suggestion has been submitted to the developer and will be reviewed soon.');
    end else
        send_message(client, msg^.channel_id, 'Please follow the "suggest" command with your suggestion for the bot.');
end;

procedure xkcd_command(client: PDiscordClient; msg: PDiscordMessage; args: array of AnsiString);
begin
    // ...
end;

{ Events }

procedure on_message(client: PDiscordClient; msg: PDiscordMessage); cdecl;
var
    args: array of AnsiString;
begin
    args := SplitString(msg^.content, ' ');
    if (Length(args) > 1) then
        if (CompareText(args[0], '<@!942991629202112603>') = 0) then
            case command_num(args[1]) of
                0: info_command(client, msg);
                1: calc_command(client, msg, args);
                2: suggest_command(client, msg, args);
                3: xkcd_command(client, msg, args);
                4: starwars_command(client, msg, args);
                5: help_command(client, msg);
                6: invite_command(client, msg);
                7: fortune_command(client, msg);
            end;
end;

{ Main }

begin
    { Read the bot token from .token }
    Assign(token_file, '.token');
    Reset(token_file);
    Readln(token_file, token);
    Close(token_file);

    { Set up the bot and connect to Discord }
    client := discord_init(PChar(token));
    discord_set_on_message_create(client, addr(on_message));
    discord_run(client);
    discord_cleanup(client);
end.