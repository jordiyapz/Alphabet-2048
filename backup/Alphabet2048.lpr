{$mode objfpc} // directive to be used for defining classes
{$m+}		   // directive to be used for using constructor

{TODO -o JordiYaputra -c : Alphabet 2048}
{Done: class console}
{Done: class board}
{Done: class game}
{Done: class controller}
{Done: class UserList}
{Done: class menu}
{Done: class HighScore}
{ToDo: class Setting}

program Alphabet2048;
Uses Crt, Math, SysUtils, Windows;

Const
  UserListFName = 'users.bin';
  //SettingFName = 'setting.bin';
  //HighscoreFName = 'hiscore.bin';
  MaxTopScore = 10;

{INTERFACE}
Type
  arrayByte = Array of byte;
  arrayStcChar = Array [0..255] of char;

  EArrow = (NUL = 0, UP, RIGHT, DOWN, LEFT);
  ESpKey = (NULL = 0, ENTER, HOME, BACKSPACE, EN, SPACE, DEL);

  Point = record
    x, y: integer;
  end;

  RUser = record
    username: String;
    nickname: String;
    password: String;
    totalScore: longInt;
  end;

  RScoreModel = record
    username: string;
    //nickname: String;
    score: longint;
  end;

  { TConsole }

  TConsole = class
  private
    x0, y0, x1, y1: integer;
    border, padding: boolean;
    procedure SetConsoleWindow(NewWidth : integer;NewHeight : integer);
  public
    width, height: integer;
    constructor create(
      const i0, j0, i1, j1: integer; const bor, pad: boolean
    );
    procedure reset();
    procedure drawBorder(const symbol: char);
    procedure writeNumRight(const num: longint; x, y: integer);
    procedure WriteAlignMiddle(const str: string; x, y: integer);
    procedure writeXY(const str: string; x, y: integer); overload;
    procedure writeXY(const num: longInt; x, y: integer);
    procedure fillBlank(const x2, y2, x3, y3: integer);
  end;

  TSetting = class
  public

  end;

  { TBoard }

  TBoard = class
  private
    table : arrayByte;
    pos : Point;
    size: byte;
    len: byte;
    score: longint;
    count: byte;
  public
    scale: byte;
    constructor create(const p: Point; siz: byte); overload;
    constructor create(const p: Point; siz, scl: byte); overload;
    procedure setSize(const siz: byte);
    function getTable(): arrayByte;
    procedure setPos(const p: Point);
    function getPos(): Point;
    procedure setVal(const val: byte); overload;
    procedure setVal(const index: byte; const val: byte);
    procedure setTable(tb: arrayByte);
    procedure insertRandom();
    function getVal(const index: byte): byte;
    procedure drawFrame();
    procedure render();
    procedure shift(dir: EArrow);
    function getScore(): longint;
    procedure setScore(const n: longInt);
    procedure addScore(const n: longInt);
    function getCount(): byte;
    procedure copyTo(var arr: arrayByte);
    function noMoveLeft(): boolean;

  end;

  { TKeyboardListener }

  TKeyboardListener = class
  public
    lastArrowKey: EArrow;
    lastSpKey: ESpKey;
    lastKey: byte;
    constructor create;
    procedure listen();
    procedure reset();
  end;

  { TUser }

  TUser = class
  private
    totalScore: longint;
    password: string;
  public
    username: string;
    nickname: string;
    constructor create(const uname, nname, pass: string); overload;
    constructor create(const rawUser: RUser); overload;
    constructor create(const uname, nname, pass: string; score: longint);
    function getScore: longint;
    procedure setScore(score: longint);
    procedure addScore(num: longint);
    function getRaw: RUser;
    function getPass(): string;
    procedure setPass(const str: string);
  end;

  { TUserList }

  TUserList = class
  private
    usersList: Array of TUser;
    procedure push(const user: TUser);
    procedure pop;
    function encrypt(const str: string): string;
    function decrypt(const str: string): string;
  public
    constructor create;
    destructor destroy;
    function isExist(const username: string): boolean;
    function getUser(const username: string) : TUser;
    function getLength(): integer;
    function getUserAt(i: byte): TUser;
    function editUsername(const username, newUname: string): byte;
    function editNickname(const username, newNickname: string): byte;
    function editPassword(const username, newPass: string): byte;
    function forgotPassword(const username, newPass: string): byte;
    function addUser(const username, nickname, password: string): byte;
    function deleteUser(const username: string): byte;
    procedure deleteAll;
    procedure dispList;
    procedure exportList;
  end;

  { TScoreList }

  TScoreList = class
  private
    scoresList: Array of RScoreModel;
    fileName: String;
    function toSModel(user: TUser; score: longint): RScoreModel; overload;
    function toSModel(const username{, nickname}: String; score: longint): RScoreModel;
    procedure sort;
    procedure push(sModel: RScoreModel);
    procedure insert(sModel: RScoreModel; index: byte);

  public
    constructor Create(const fname: String);
    function getAt(id: byte): rScoreModel;
    function getLength: byte;
    procedure pop;
    procedure checkin(user: TUser; score: longint);
    procedure displayList;
    procedure deleteAll;
    procedure deleteAt(index: byte);
    procedure exportList;
  end;

  RHistoryModel = record
    table: arrayByte;
    score: longInt;
  end;

  { TGameSystem }

  TGameSystem = class
  private
    keyboard: TKeyboardListener;
    historyPool: Array of RHistoryModel;
    maxUndo: byte;
  public
    size: byte;
    board: TBoard;
    procedure pour(arr: arrayByte; score: longInt);
    function slurp(): RHistoryModel;
    procedure drainPool();
    procedure undo();
    procedure restart();
    procedure gameOver();
    function isDiff(const arr1, arr2: arrayByte): boolean;
    procedure update(var exitState: boolean; var flag: string);
    procedure render(var flag: string);
    procedure listen();
    procedure setup();
    procedure play();
    constructor create(const siz: byte);
    destructor destroy();
    procedure routine();
  end;

  { TInputBox }

  TInputBox = class
  private
    keyboard: TKeyboardListener;
    dispIdx: byte;
    cursor: byte;
    procedure insert(const c: char);
    procedure remove;
    procedure delete;
    procedure moveCursor(const dir: EArrow);
    procedure update(var exitState: boolean);
    procedure listen(var exitState: boolean);
  public
    content: arrayStcChar;
    width: byte;
    maxChar: byte;
    masking: boolean;
    pos: Point;
    len: byte;
    constructor create(keyb: TKeyboardListener); overload;
    constructor create(keyb: TKeyboardListener;
      wid: byte; x, y: byte; maxCh: byte = 255; mask: boolean = false
    );
    procedure setup(wid: byte; x, y: byte; maxCh: byte = 255; mask: boolean = false);
    procedure render;
    procedure showCursor;
    procedure setPos(const x, y: byte);
    function getContent: string;
    function rawRender: string;
    procedure routine;
  end;

  { TCheckBox }

  TCheckBox = class
    keyboard: TKeyboardListener;
    procedure listen(var exitState: boolean);
  public
    value: boolean;
    message: string;
    pos: Point;
    constructor create(keyb: TKeyboardListener); overload;
    constructor create(
      keyb: TKeyboardListener;
      const x, y: byte;
      const msg: string = '';
      val: boolean = false
    );
    procedure trigger;
    procedure render;
    procedure drawInit;
    procedure routine;
  end;

  EMenuPages = (
    pStartPage = 0, pMainMenu, pPlayGame, pLogin, pHighscore
  );

  { TMainSystem }

  TMainSystem = class
  private
    currentPage, prevPage: EMenuPages;
    arrowL, arrowR: point;
    arrowRactive: boolean;
    scorelist: TScoreList;
    userlist: TUserList;
    currentUser: TUser;
    game: TGameSystem;
    boardSize: byte;
    tmpBoard: arrayByte;
    keyboard: TKeyboardListener;
    inputBoxes: array [0..4] of TInputBox;
    checkBoxes: array [0..1] of TCheckBox;
    framecount: longint;
    delaytime: byte;
    procedure drawArrow(const a: byte);
    procedure undrawArrow();
    procedure setArrow(const x, y: byte);
    procedure setArrow(const xl, yl, xr, yr: byte);
    procedure setArrow(var arrow: Point; const x, y: byte);
    procedure drawRect(const x1, y1, x2, y2: byte);
    procedure drawRoundBox(const x1, y1, x2, y2: byte);
    procedure drawSlantBox(const x1, y1, x2, y2: byte);
    procedure setup(var changePage, exitState: boolean; var flag: string; var store: arrayByte);
    procedure drawPage();
    procedure update(var changePage, exitState: boolean; var flag: string; var store: arrayByte);
    procedure render(var flag: string; var store: arrayByte);
    procedure listen(var changePage, exitState: boolean; var flag: string; var store: arrayByte);
  public
    constructor create;
    destructor destroy;
    procedure routine;
  end;

  {IMPLEMENTATION}

Var
  console: TConsole;
  setting: TSetting;
function toStr(const arrCh: arrayStcChar; const len: byte): string; forward;
function subStr(const str: string; start, len: integer): string; forward;

{ TCheckBox }

procedure TCheckBox.listen(var exitState: boolean);
begin
  keyboard.reset;
  keyboard.listen;
  if keyboard.lastSpKey in [ENTER, SPACE] then begin
    trigger;
    exitState:= true;
    keyboard.reset;
  end else
  if (keyboard.lastArrowKey in [UP, DOWN]) then begin
    exitState:= true;
  end;
end;

constructor TCheckBox.create(keyb: TKeyboardListener);
begin
  create(keyb, 1, 1);
end;

constructor TCheckBox.create(keyb: TKeyboardListener; const x, y: byte; const msg: string; val: boolean);
begin
  keyboard:= keyb;
  pos.x:= x;
  pos.y:= y;
  message:= msg;
  value:= val;
end;

procedure TCheckBox.trigger;
begin
  value:= not value;
end;

procedure TCheckBox.render;
var c: char;
begin
  if value then c:= 'Y' else c:= 'X';
  console.writeXY(c, pos.x + 1, pos.y);
end;

procedure TCheckBox.drawInit;
begin
  console.writeXY('[', pos.x, pos.y);
  console.writeXY(']', pos.x + 2, pos.y);
  console.writeXY(message, pos.x + 4, pos.y);
end;

procedure TCheckBox.routine;
var exitState: boolean;
begin
  exitState:= false;
  drawInit;
  repeat
    render;
    gotoXY(pos.x + 1, pos.y);
    cursoron;
    listen(exitState);
  until exitState;
  cursoroff;
end;

{ TInputBox }

procedure TInputBox.insert(const c: char);
var
  i: byte;
begin
  if len < maxChar then begin
    inc(len);
    i:= len;
    while (i > cursor) do begin
      content[i]:= content[i - 1];
      dec(i);
    end;
    content[cursor]:= c;
    moveCursor(RIGHT);
  end;

end;

procedure TInputBox.remove;
var
  i: byte;
begin
  if cursor > 0 then begin
    i:= cursor - 1;
    while (i < len) do begin
      content[i]:= content[i + 1];
      inc(i);
    end;
    dec(len);
    moveCursor(LEFT);
  end;
end;

procedure TInputBox.delete;
var i: byte;
begin
  if cursor <= len then begin
    moveCursor(RIGHT);
    remove;
  end;
end;

procedure TInputBox.moveCursor(const dir: EArrow);
begin
  case dir of
    LEFT: begin
      if cursor > 0 then
        dec(cursor);
      if cursor < dispIdx then
        dec(dispIdx);
    end;
    RIGHT: begin
      if cursor < len then
        inc(cursor);
      if cursor > dispIdx + width then
        inc(dispIdx);
    end;
    else begin end;
  end;
end;

procedure TInputBox.update(var exitState: boolean);
begin

end;

procedure TInputBox.render;
var i: byte;
begin
  gotoXY(pos.x, pos.y);
  for i:= 1 to width do
    write(' ');
  i:= dispIdx;
  gotoXY(pos.x, pos.y);
  while (i < len) and (i < dispIdx + width) do begin
    if masking then write('*')
    else write(content[i]);
    inc(i);
  end;
end;

procedure TInputBox.showCursor;
begin
  cursoron;
  gotoXY(pos.x + cursor - dispIdx, pos.y);
end;

procedure TInputBox.setPos(const x, y: byte);
begin
  pos.x:= x;
  pos.y:= y;
end;

function TInputBox.getContent: string;
begin
  getContent:= toStr(content, len);
end;

function TInputBox.rawRender: string;
var
  i: byte;
  arCh: arrayStcChar;
begin
  for i:= 1 to width do
    arCh[i]:= ' ';
  i:= dispIdx;
  while (i < len) and (i < dispIdx + width) do begin
    if masking then arCh[i-dispIdx]:= '*'
    else arCh[i-dispIdx]:= content[i];
    inc(i);
  end;
  rawRender:= toStr(arCh, width);
end;

procedure TInputBox.listen(var exitState: boolean);
begin
  keyboard.reset;
  keyboard.listen;
  if keyboard.lastArrowKey <> NUL then begin
    case keyboard.lastArrowKey of
      LEFT: moveCursor(LEFT);
      RIGHT: moveCursor(RIGHT);
      else exitState:= true;
    end;
    if keyboard.lastArrowKey <> UP then
      keyboard.reset;
  end else
  if keyboard.lastSpKey <> NULL then begin
    case keyboard.lastSpKey of
      ENTER: exitState:= true;
      SPACE: insert(' ');
      BACKSPACE: remove;
      DEL: delete;
      HOME: cursor:= 0;
      EN: cursor:= len - 1;
    end;
    keyboard.reset;
  end else begin
    if keyboard.lastKey in [33..126] then
      insert(char(keyboard.lastKey));
    keyboard.reset;
  end;
end;

constructor TInputBox.create(keyb: TKeyboardListener);
begin
  cursor:= 0;
  dispIdx:= 0;
  len:= 0;
  setup(20, 1, 1);
  keyboard:= keyb;
end;

constructor TInputBox.create(keyb: TKeyboardListener; wid: byte; x, y: byte;
  maxCh: byte; mask: boolean);
begin
  create(keyb);
  setup(wid, x, y, maxCh, mask);
end;

procedure TInputBox.setup(wid: byte; x, y: byte; maxCh: byte; mask: boolean);
begin
  width:= wid;
  setPos(x, y);
  maxChar:= maxCh;
  masking:= mask;
end;

procedure TInputBox.routine;
var
  exitState: boolean;
begin
  exitState:= false;
  repeat
    update(exitState);
    cursoroff;
    render;
    showCursor;
    listen(exitState);
  until exitState;
  cursoroff;
end;

{ TMainSystem }

procedure TMainSystem.drawArrow(const a: byte);
begin
  gotoXY(arrowL.x-1, arrowL.y);
  if a mod 2 = 0 then write('->')
  else write('--');
  if arrowRactive then
  begin
    gotoXY(arrowR.x, arrowR.y);
    if a mod 2 = 0 then write('<-')
    else write('--');
  end;
end;

procedure TMainSystem.undrawArrow();
begin
  gotoXY(arrowL.x-1, arrowL.y);
  write('  ');
  if arrowRactive then
  begin
    gotoXY(arrowR.x, arrowR.y);
    write('  ');
  end;
end;

procedure TMainSystem.setArrow(const x, y: byte);
begin
  arrowL.x:= x;
  arrowL.y:= y;
end;

procedure TMainSystem.setArrow(const xl, yl, xr, yr: byte);
begin
  arrowL.x:= xl;
  arrowL.y:= yl;
  arrowR.x:= xr;
  arrowR.y:= yr;
end;

procedure TMainSystem.setArrow(var arrow: Point; const x, y: byte);
begin
  arrow.x:= x;
  arrow.y:= y;
end;

procedure TMainSystem.drawRect(const x1, y1, x2, y2: byte);
var
  j: byte;
  buff: string;
begin
  buff:= '';
  for j:= x1 to x2 do
    if j in [x1, x2] then
      buff:= buff+'+'
    else
      buff:= buff+'-';
  for j:= y1 to y2 do
  begin
    gotoXY(x1, j);
    if j in [y1, y2] then
      write(buff)
    else begin
      write('|');
      gotoXY(x2, j);
      write('|');
    end;
  end;
end;

procedure TMainSystem.drawRoundBox(const x1, y1, x2, y2: byte);
var
  i: byte;
  buff: string = '';
begin
  for i:= x1+1 to x2-1 do
    if i in [x1+1, x2-1] then
      buff:= buff + 'o'
    else
      buff:= buff + '-';
  for i:= y1 to y2 do
  begin
    if (i in [y1, y2]) then
      console.writeXY(buff, x1+1, i)
    else if (y2 - y1 > 2) and (i = y1 + 1) then
    begin
      console.writeXY('/', x1, i);
      console.writeXY('\', x2, i);
    end
    else if (y2 - y1 > 2) and (i = y2 - 1) then
    begin
      console.writeXY('\', x1, i);
      console.writeXY('/', x2, i);
    end
    else begin
      console.writeXY('|', x1, i);
      console.writeXY('|', x2, i);
    end;
  end;
end;

procedure TMainSystem.drawSlantBox(const x1, y1, x2, y2: byte);
var
  i: byte;
  buff: string;
begin
  buff:= '';
  for i:= 1 to (x2-x1)-(y2-y1) do
    buff:= buff + '-';
  for i:= 0 to y2-y1 do begin
    gotoXY(x1 + i, y1 + i);
    if (i in [0, (y2-y1)]) then begin
      if (i = 0) then write('<');
      write(buff);
      if (i = y2-y1) then write('>');
    end
    else begin
      write('\');
      console.writeXY('\', x2 - (y2-y1) + i , y1 + i);
    end;
  end;
end;

procedure TMainSystem.setup(var changePage, exitState: boolean;
  var flag: string; var store: arrayByte);
var
  i: byte;
begin
  case currentPage of
    pStartPage: begin
      setArrow(31, 27, 44, 27);
      arrowRactive:= true;
    end;
    pLogin: begin
      setArrow(66, 27, 73, 27);
      arrowRactive:= true;
      if length(store) <> 4 then
        setLength(store, 4);
      //store[0] = ulist start,
      //store[1] = select user,
      //store[2] = message flag,
      //store[3] = counter;
      for i:= 0 to 3 do
        store[i]:= 0;
      flag:= 'init';
    end;
    pMainMenu: begin
      setArrow(13, 6, 1, 1);
      arrowRactive:= false;
      if length(store) <> 1 then
        setLength(store, 1);
      store[0]:= 4;
      flag:= 'init';
    end;
    pPlayGame: begin
      delayTime:= 0;
      //boardSize:= 3;
      case boardSize of
        3: scorelist:= TScoreList.create('3x3.bin');
        4: scorelist:= TScoreList.create('4x4.bin');
        5: scorelist:= TScoreList.create('5x5.bin');
        6: scorelist:= TScoreList.create('6x6.bin');
        //7: scorelist:= TScoreList.create('7x7.bin');
        //8: scorelist:= TScoreList.create('8x8.bin');
        else scorelist:= TScoreList.create('what.bin');
      end;
      game:= TGameSystem.create(boardSize);
      setLength(tmpBoard, boardSize*boardSize);
      if length(store) <> 1 then
        setLength(store, 1);
      game.board.insertRandom();
      game.pour(game.board.getTable(), game.board.getScore());
      store[0]:= 1;
      game.board.copyTo(tmpBoard);
      flag:= 'init';
    end;
    pHighscore: begin
      if length(store) <> 2 then
        setLength(store, 1);
      store[0]:= 4;
      store[1]:= 0;
      setArrow(4, 27, 11, 27);
      flag:= 'initChange';
    end;
  end;
end;

procedure TMainSystem.drawPage();
var
  f: textFile;
  x, y, e: byte;
  buff: string;
begin
  case currentPage of
    pStartPage: begin
      assign(f,'AsciiArtAlphabet2048.txt');
      try
        reset(f);
      except
        console.writeAlignMiddle('Alphabet 2048', console.width div 2, 10);
        rewrite(f);
        reset(f);
      end;
      y:= 2;
      x:= 6;
      while not eof(f) do
      begin
        readln(f, buff);
        gotoXY(x, y);
        write(buff);
        inc(y);
      end;
      close(f);
      console.WriteAlignMiddle(
        'START GAME',
        console.width div 2, y+2
      );
      y:= 26;
      x:= 61;
      console.writeXY('Created by:',x, y);
      console.writeXY('Jordi Yaputra',x+2, y+1);
    end;
    pLogin: begin
      drawRect(3, 2, console.width-2, 4);
      console.writeXY('Play as:', 5, 3);
      drawRect(3, 6, 56, 8); //UserSelectBoxHeader
      drawRect(3, 8, 56, console.height-6); //userSelectBox
      drawRect(3, console.height-4, console.width-2, console.height-2);
      console.writeAlignMiddle('Create New User',console.width div 2, 24);
      drawRect(58, 6, console.width-2, 8);
      x:= 63;
      console.writeXY('Login', x, 7);
      drawRect(58, 10, console.width-2, 12);
      console.writeXY('Edit', x, 11);
      drawRect(58, 14, console.width-2, 16);
      console.writeXY('Delete', x, 15);
      gotoXY(6, console.height);
      write('Back');
      gotoXY(console.width-8, console.height);
      write('Done');
    end;
    pMainMenu: begin
      x:= 6;
      y:= 4;
      drawSlantBox(x, y, x + 68,y+4);
      console.writeXY('Play Game', x + 9, y + 2);
      inc(x, 5); inc(y, 6);
      drawSlantBox(x, y, x + 27,y+4);
      console.writeXY('Change User', x + 9, y + 2);
      inc(x, 5); inc(y, 6);
      drawSlantBox(x, y, x + 26,y+4);
      console.writeXY('High Score', x + 9, y + 2);
      inc(x, 5); inc(y, 6);
      drawSlantBox(x, y, x + 21,y+4);
      console.writeXY('Exit', x + 9, y + 2);
      x:= 45;
      y:= 10;
      console.writeXY('#   #   #   ### #   #', x, y + 0);
      console.writeXY('## ##  # #   #  ##  #', x, y + 1);
      console.writeXY('# # # #####  #  # # #', x, y + 2);
      console.writeXY('# # # #   #  #  #  ##', x, y + 3);
      console.writeXY('# # # #   # ### #   #', x, y + 4);
      x:= x + 4;
      y:= y + 6;
      console.writeXY('#   # ##### #   # #   #', x, y);
      console.writeXY('## ## #     ##  # #   #', x, y+1);
      console.writeXY('# # # ####  # # # #   #', x, y+2);
      console.writeXY('# # # #     #  ## #   #', x, y+3);
      console.writeXY('# # # ##### #   #  ### ', x, y+4);
    end;
    pPlayGame: begin
      console.writeXY('Score:', 2, 2);
    end;
    pHighscore: begin
      x:= 2;
      y:= 2;
      drawRect(x, y, console.width, y + 2);
      console.writeAlignMiddle('TOP 10 HIGHSCORES', console.width div 2, y + 1);
      drawRect(x, y + 2, console.width, 24);
      console.writeXY('Back', 6, console.height);
    end;
  end;
end;

procedure TMainSystem.update(var changePage, exitState: boolean;
  var flag: string; var store: arrayByte);
var i: byte;
begin
  case currentPage of
    pStartPage: begin
    end;
    pLogin: begin
      case flag of
        '': begin
          if (store[3] > 0) then dec(store[3]);
        end;
        'initCreateUser': begin
          for i:= 0 to 3 do
            inputBoxes[i]:= TInputBox.create(keyboard, 30, 16, 10 + i*2);
          inputBoxes[2].masking:= true;
          inputBoxes[3].setup(30, 25, 16, 255, true);
        end;
        'initLogin': begin
          inputBoxes[0]:= TInputBox.create(keyboard, 20, 16, 12, 255, true);
          checkBoxes[0]:= TCheckbox.create(keyboard, 16, 13, 'Show Password');
        end;
        'login': begin
          inputBoxes[0].masking:= not checkBoxes[0].value
        end;
        'initEdit': begin
          for i:= 0 to 3 do
            inputBoxes[i]:= TInputBox.create(keyboard, 30, 16, 10 + i*2);
          inputBoxes[2].masking:= true;
          inputBoxes[3].setup(30, 25, 16, 255, true);
        end;
        'initFPass': begin
          for i:= 1 to 3 do
            inputBoxes[i]:= TInputBox.create(keyboard, 30, 16, 10 + i*2);
          inputBoxes[2].masking:= true;
          inputBoxes[3].setup(30, 25, 16, 255, true);
        end;
      end;
    end;
    pMainMenu: begin
      case flag of
        '': begin
          if (ArrowL.y = 6) then
            arrowRactive:= false
          else
            arrowRactive:= true;
        end;
      end;
    end;
    pPlayGame: begin
      case flag of
        'init': begin
          delayTime:= 0;
        end;
        'play': begin
          console.writeXY('      ', 2, 4);
          if game.board.noMoveLeft then begin
            flag:= 'initGameover';
            arrowRactive:= true;
            setArrow(34, 12, 41, 12);
            delayTime:= 200;
          end else begin
            if game.isDiff(tmpBoard, game.board.getTable) then begin
              console.writeXY('change', 2, 4);
              game.board.copyTo(tmpBoard);
              game.pour(tmpBoard, game.board.getScore());
              if store[0] < 3 then
                inc(store[0]);
              game.board.insertRandom();
            end;
            game.board.copyTo(tmpBoard);
          end;
        end;
        'initPause': begin
          arrowRactive:= true;
          setArrow(33, 12, 42, 12);
        end;
        'undo': begin
          dec(store[0]);
          game.undo();
          game.board.copyTo(tmpBoard);
          flag:= 'play';
        end;
      end;
    end;
    pHighScore: begin
      case flag of
        'initChange': begin
          store[1]:= 0;
          case store[0] of
            3: scorelist:= TScoreList.create('3x3.bin');
            4: scorelist:= TScoreList.create('4x4.bin');
            5: scorelist:= TScoreList.create('5x5.bin');
            6: scorelist:= TScoreList.create('6x6.bin');
            //7: scorelist:= TScoreList.create('7x7.bin');
            //8: scorelist:= TScoreList.create('8x8.bin');
            else scorelist:= TScoreList.create('what.bin');
          end;
        end;
      end;
    end;
  end;
end;

procedure TMainSystem.render(var flag: string; var store: arrayByte);
var
  i, x, y: byte;
  buff: string;
begin
  case currentPage of
    pStartPage: begin
      case flag of
        '': drawArrow(framecount mod 2);
        'change': begin
          undrawArrow;
          for i:= 28 downto 0 do
          begin
            writeln;
            sleep(20);
          end;
          flag:= 'next';
        end;
      end;
    end;
    pLogin: begin
      case flag of
        'init': begin
          console.fillBlank(14, 3, 73, 3);
          console.fillBlank(4, 7, 55, 7);
          console.fillBlank(4, 9, 55, console.height-7);
          console.writeAlignMiddle('Username list', 3 + (56 - 3) div 2, 7);
          flag:= '';
        end;
        '': begin
          drawArrow(framecount mod 2);
          console.writeXY(subStr(currentUser.username, 1, 59), 14, 3);
          i:= 0;
          while (i < 6) and (i < userlist.getLength()) do begin
            console.writeXY(
              subStr(userlist.getUserAt(i+store[0]).username, 1, 48),
              7, 9 + i*2
            );
            if (i + store[0] = store[1]) then
              console.writeXY('>', 5, 9 + i*2);
            inc(i);
          end;
          if store[2] <> 0 then
            if store[3] > 0 then begin
              case store[2] of
                1: begin
                  textColor(LightGreen);
                  buff:= 'You''ve logged in as ' + currentUser.username;
                  console.writeAlignMiddle(buff, console.width div 2, 5);
                  textColor(LightGray);
                end;
                2: begin
                  textColor(LightGreen);
                  buff:= 'Logged in as ' + currentUser.username;
                  console.writeAlignMiddle(buff, console.width div 2, 5);
                  textColor(LightGray);
                end;
                3: begin
                  textColor(LightRed);
                  buff:= 'You must log in as ' + userlist.getUserAt(store[1]).username;
                  console.writeAlignMiddle(buff, console.width div 2, 5);
                  textColor(LightGray);
                end;
                4: begin
                  textColor(LightRed);
                  buff:= 'You cannot edit user:' + userlist.getUser('').username;
                  console.writeAlignMiddle(buff, console.width div 2, 5);
                  textColor(LightGray);
                end;
                5: begin
                  textColor(LightRed);
                  buff:= 'You cannot delete user:' + userlist.getUser('').username;
                  console.writeAlignMiddle(buff, console.width div 2, 5);
                  textColor(LightGray);
                end;
                6: begin
                  textColor(LightGreen);
                  buff:= 'Delete successful';
                  console.writeAlignMiddle(buff, console.width div 2, 5);
                  textColor(LightGray);
                end;
                7: begin
                  textColor(LightGreen);
                  buff:= 'Edit successful';
                  console.writeAlignMiddle(buff, console.width div 2, 5);
                  textColor(LightGray);
                end;
              end;
            end else begin
              console.fillBlank(4, 5, 73, 5);
              store[2]:= 0;
            end;
        end;
        'select': begin
          i:= 0;
          while (i < 6) and (i < userlist.getLength()) do begin
            console.fillBlank(4, 9 + i*2, 55, 9 + i*2);
            console.writeXY(
              subStr(userlist.getUserAt(i+store[0]).username, 1, 48),
              7, 9 + i*2
            );
            if (i + store[0] = store[1]) then
              if (framecount mod 2 = 0) then
                console.writeXY('>', 5, 9 + i*2)
              else
                console.writeXY('-', 5, 9 + i*2)
            else
              console.writeXY(' ', 5, 9 + i*2);
            inc(i);
          end;
        end;
        'initCreateUser': begin
          console.fillBlank(4, 9, 55, console.height-7);
          console.fillBlank(4, 7, 53, 7);
          console.writeAlignMiddle('Create New User', 3 + (56 - 3) div 2, 7);
          flag:= 'createUser';
          x:= 6;
          y:= 10;
          console.writeXY('Username:', x, y);
          console.writeXY('Nickname:', x, y + 2);
          console.writeXY('Password:', x, y + 4);
          console.writeXY('re-enter Password:', x, y + 6);
          console.writeXY('Cancel', x + 2, y + 9);
          console.writeXY('Create', 45, y + 9);
        end;
        'createUser': begin
          for i:= 0 to 3 do begin
            console.fillBlank(
              inputBoxes[i].pos.x,
              10 + i*2,
              inputBoxes[i].pos.x + inputBoxes[i].width,
              10 + i*2
            );
            console.writeXY(
              inputBoxes[i].rawRender,
              inputBoxes[i].pos.x,
              10 + i*2
            );
          end;
          if arrowL.y = 19 then
            drawArrow(framecount);
        end;
        'initLogin': begin
          console.fillBlank(4, 9, 55, console.height-7);
          console.fillBlank(4, 7, 53, 7);
          console.writeAlignMiddle('Login', 3 + (56 - 3) div 2, 7);
          x:= 6;
          y:= 10;
          console.writeXY('Username:', x, y);
          console.writeXY(
            subStr(userlist.getUserAt(store[1]).username, 1, 30),
            x + 10, y
          );
          console.writeXY('Password:', x, y + 2);
          checkBoxes[0].drawInit;
          checkBoxes[0].render;
          console.writeXY('Forgot Password?', x + 2, y + 7);
          console.writeXY('Cancel', x + 2, y + 9);
          console.writeXY('Login', 46, y + 9);
          flag:= 'login';
        end;
        'login': begin
          console.fillBlank(
            inputBoxes[0].pos.x, 12,
            inputBoxes[0].pos.x + inputBoxes[0].width, 12
          );
          console.writeXY(inputBoxes[0].rawRender, inputBoxes[0].pos.x, 12);
          if arrowL.y in [17, 19] then
            drawArrow(framecount);
        end;
        'initEdit': begin
          console.fillBlank(4, 9, 55, console.height-7);
          console.fillBlank(4, 7, 53, 7);
          buff:= 'Edit user:' + currentUser.username;
          console.writeAlignMiddle(buff, 3 + (56 - 3) div 2, 7);
          flag:= 'edit';
          x:= 6;
          y:= 10;
          console.writeXY('Username:', x, y);
          console.writeXY('Nickname:', x, y + 2);
          console.writeXY('Password:', x, y + 4);
          console.writeXY('re-enter Password:', x, y + 6);
          console.writeXY('Cancel', x + 2, y + 9);
          console.writeXY('Done', 47, y + 9);
        end;
        'edit': begin
          for i:= 0 to 3 do begin
            console.fillBlank(
              inputBoxes[i].pos.x,
              10 + i*2,
              inputBoxes[i].pos.x + inputBoxes[i].width,
              10 + i*2
            );
            console.writeXY(
              inputBoxes[i].rawRender,
              inputBoxes[i].pos.x,
              10 + i*2
            );
          end;
          if arrowL.y = 19 then
            drawArrow(framecount);
        end;
        'initDelete': begin
          console.fillBlank(4, 7, 53, 7);
          buff:= 'Delete user:' + currentUser.username;
          console.writeAlignMiddle(buff, 3 + (56 - 3) div 2, 7);
          x:= 19;
          y:= 11;
          console.fillBlank(x, y, x + 21, y + 6);
          drawRect(x, y, x + 21, y + 6);
          console.writeAlignMiddle('Are you sure?', 3 + (56 - 3) div 2, y + 2);
          console.writeXY('No', x + 5, y + 4);
          console.writeXY('Yes', x + 14, y + 4);
          flag:= 'delete';
        end;
        'delete': begin
          drawArrow(framecount);
        end;
        'initFPass': begin
          console.fillBlank(4, 9, 55, console.height-7);
          console.fillBlank(4, 7, 53, 7);
          buff:= 'Forgot Password user:' + currentUser.username;
          console.writeAlignMiddle(buff, 3 + (56 - 3) div 2, 7);
          flag:= 'fPass';
          x:= 6;
          y:= 10;
          console.writeXY('Username:', x, y);
          console.writeXY(userlist.getUserAt(store[1]).username, x + 11, y);
          console.writeXY('Nickname:', x, y + 2);
          console.writeXY('Password:', x, y + 4);
          console.writeXY('re-enter Password:', x, y + 6);
          console.writeXY('Cancel', x + 2, y + 9);
          console.writeXY('Done', 47, y + 9);
        end;
        'fPass': begin
          for i:= 1 to 3 do begin
            console.fillBlank(
              inputBoxes[i].pos.x,
              10 + i*2,
              inputBoxes[i].pos.x + inputBoxes[i].width,
              10 + i*2
            );
            console.writeXY(
              inputBoxes[i].rawRender,
              inputBoxes[i].pos.x,
              10 + i*2
            );
          end;
          if arrowL.y = 19 then
            drawArrow(framecount);
        end;
      end;
    end;
    pMainMenu: begin
      case flag of
        'init': begin
          gotoXY(4, 2);
          write('Welcome, ', currentUser.nickname);
          console.writeXY('Board Size:', 35, 6);
          flag:= '';
        end;
        '': begin
          drawArrow(framecount);
          x:= 51;
          y:= 6;
          gotoXY(x, y);
          write(store[0], ' x ', store[0]);
          gotoXY(x - 2, y);
          if store[0] > 3 then
            write('<')
          else write(' ');
          gotoXY(x + 6, y);
          if store[0] < 6 then
            write('>')
          else write(' ');
        end;
      end;
    end;
    pPlayGame: begin
      case flag of
        'init': begin
          x:= game.board.getPos.x;
          y:= game.board.getPos.y;
          i:= game.size * game.board.scale * 2;
          console.fillBlank(x, y, x + i*2, y + i);
          game.board.drawFrame();
          flag:= 'play';
        end;
        'play': begin
          game.board.render();
          console.writeNumRight(game.board.getScore, 15, 2);
        end;
        'initPause': begin
          x:= console.width div 2;
          y:= 10;
          drawRect(x - 10, y, x + 10, y + 8);
          console.fillBlank(x - 9, y + 1, x + 9, y + 7);
          console.writeAlignMiddle('Resume', x, y + 2);
          console.writeAlignMiddle('Restart', x,  y + 4);
          console.writeAlignMiddle('Exit', x,  y + 6);
          flag:= 'pause';
        end;
        'pause': begin
          drawArrow(framecount);
        end;
        'initGameover': begin
          x:= console.width div 2;
          y:= 10;
          drawRect(x - 10, y, x + 10, y + 8);
          console.fillBlank(x - 9, y + 1, x + 9, y + 7);
          console.writeAlignMiddle('Undo', x, y + 2);
          console.writeAlignMiddle('Restart', x,  y + 4);
          console.writeAlignMiddle('Exit', x,  y + 6);
          flag:= 'gameover';
        end;
        'gameover': begin
          drawArrow(framecount);
        end;
      end;
    end;
    pHighScore: begin
      case flag of
        'initChange': begin
          console.fillBlank(3, 5, console.width - 1, 23);
          x:= console.width div 2;
          y:= 25;
          gotoXY(x-2, y);
          write(store[0], ' x ', store[0]);
          flag:= '';
          x:= 4;
          y:= 5;
          i:= store[1];
          if scorelist.getLength = 0 then
            console.writeAlignMiddle(
              '<--------- No Data --------->',
              console.width div 2, y
            );
          while (i < 10) and (i < scorelist.getLength) do
          begin
            textColor(7);
            if (scorelist.getAt(i).username = currentUser.username) then
              textColor(10);
            console.WriteNumRight(i+1, x + 2, y + i*2);
            console.writeXY('.', x + 2, y + i*2);
            console.writeXY(scorelist.getAt(i).username, x + 3, y + i*2);
            console.writeNumRight(scorelist.getAt(i).score, console.width - 3, y + i*2);
            inc(i);
          end;
          textColor(7);
        end;
        '': begin
          x:= console.width div 2;
          y:= 25;
          gotoXY(x - 4, y);
          if store[0] > 3 then write('<')
          else write(' ');
          gotoXY(x + 4, y);
          if store[0] < 6 then write('>')
          else write(' ');
          case arrowL.y of
            27: drawArrow(framecount);
            25: begin
              gotoXY(x - 4, y);
              if (store[0] > 3) and (framecount mod 2 = 1) then
                write('-');
              gotoXY(x + 4, y);
              if (store[0] < 6) and (framecount mod 2 = 1) then
                write('-');
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TMainSystem.listen(var changePage, exitState: boolean;
  var flag: string; var store: arrayByte);
var
  x, y: byte;
  user: TUser;
begin
  if keyPressed then
  begin
    keyboard.reset;
    keyboard.listen;
  end;
  case currentPage of
    pStartPage: begin
      if (arrowL.x = 31) and (arrowL.y = 27) then
        case flag of
          '':
            if (keyboard.lastSpKey = ENTER) then
            begin
              flag:= 'change';
              keyboard.reset;
            end;
          'next': begin
            flag:= 'init';
            changePage:= true;
            prevPage:= currentPage;
            currentPage:= pLogin;
          end;
        end;
    end;
    pLogin: begin
      case flag of
        '': begin
          case arrowL.y of
            27: begin //back and done
              if keyboard.lastArrowKey in [UP, DOWN] then begin
                undrawArrow;
                case keyboard.lastArrowKey of
                  UP: setArrow(29, 24, 47, 24);
                  DOWN: setArrow(61, 7, 69, 7);
                end;
                keyboard.reset;
              end
              else case arrowL.x of
                4: begin //Back
                  if keyboard.lastSpKey = ENTER then
                  begin
                    currentPage:= prevPage;
                    changePage:= true;
                    keyboard.reset;
                  end else
                  if keyboard.lastArrowKey = RIGHT then
                  begin
                    undrawArrow();
                    setArrow(66, 27, 73, 27);
                    keyboard.reset;
                  end;
                end;
                66: begin //Done
                  if keyboard.lastSpKey = ENTER then begin
                    currentPage:= pMainMenu;
                    changePage:= true;
                    keyboard.reset;
                  end else
                  if keyboard.lastArrowKey = LEFT then begin
                    undrawArrow();
                    setArrow(4, 27, 11, 27);
                    keyboard.reset;
                  end;
                end;
              end;
            end;
            24: begin //Create new user
              if keyboard.lastArrowKey <> NUL then begin
                undrawArrow;
                case keyboard.lastArrowKey of
                  DOWN: setArrow(66, 27, 73, 27);
                  RIGHT: setArrow(66, 27, 73, 27);
                  LEFT: setArrow(4, 27, 11, 27);
                  UP: setArrow(61, 15, 70, 15);
                end;
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER then begin
                drawArrow(0);
                setArrow(6, 19, 15, 19);
                flag:= 'initCreateUser';
                keyboard.reset;
              end;
            end;
            7..15: begin
              if keyboard.lastArrowKey = LEFT then begin
                undrawArrow;
                flag:= 'select';
                keyboard.reset;
              end else begin
                case arrowL.y of
                  15: begin // Delete
                    if keyboard.lastArrowKey in [UP, DOWN] then begin
                      undrawArrow;
                      case keyboard.lastArrowKey of
                        UP: setArrow(61, 11, 68, 11);
                        DOWN: setArrow(29, 24, 47, 24);
                      end;
                      keyboard.reset;
                    end else
                    if keyboard.lastSpKey = ENTER then begin
                      undrawArrow;
                      if (userlist.getUserAt(store[1]).username <> 'guest')
                      then
                        if (currentUser.username =
                        userlist.getUserAt(store[1]).username)
                        then begin
                          setArrow(22, 15, 27, 15);
                          flag:= 'initDelete';
                        end else begin
                          store[2]:= 3;
                          store[3]:= 8;
                        end
                      else begin
                        store[2]:= 5;
                        store[3]:= 8;
                      end;
                      keyboard.reset;
                    end;
                  end;
                  11: begin // Edit
                    if keyboard.lastArrowKey in [UP, DOWN] then begin
                      undrawArrow;
                      case keyboard.lastArrowKey of
                        UP: setArrow(61, 7, 69, 7);
                        DOWN: setArrow(61, 15, 70, 15);
                      end;
                      keyboard.reset;
                    end else
                    if keyboard.lastSpKey = ENTER then begin
                      undrawArrow;
                      if (userlist.getUserAt(store[1]).username <> 'guest')
                      then
                        if (currentUser.username =
                        userlist.getUserAt(store[1]).username)
                        then begin
                          setArrow(6, 19, 15, 19);
                          flag:= 'initEdit';
                        end else begin
                          store[2]:= 3;
                          store[3]:= 8;
                        end
                      else begin
                        store[2]:= 4;
                        store[3]:= 8;
                      end;
                      keyboard.reset;
                    end;
                  end;
                  7: begin // Login
                    if keyboard.lastArrowKey <> NUL then begin
                      undrawArrow;
                      case keyboard.lastArrowKey of
                        UP: setArrow(66, 27, 73, 27);
                        DOWN: setArrow(61, 11, 68, 11);
                      end;
                      keyboard.reset;
                    end else
                    if keyboard.lastSpKey = ENTER then begin
                      undrawArrow;
                      if (currentUser.username <>
                        userlist.getUserAt(store[1]).username)
                      then
                        if (userlist.getUserAt(store[1]).username = 'guest')
                        then begin
                          flag:= 'init';
                          currentUser:= userlist.getUser('');
                          store[2]:= 2;
                          store[3]:= 8;
                        end else begin
                          setArrow(6, 19, 15, 19);
                          flag:= 'initLogin';
                        end
                      else begin
                        store[2]:= 1;
                        store[3]:= 8;
                      end;
                      keyboard.reset;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
        'select': begin
          if keyboard.lastArrowKey in [UP, DOWN, RIGHT] then begin
            case keyboard.lastArrowKey of
              RIGHT: flag:= '';
              UP:
                if (store[1] > 0) then begin
                  dec(store[1]);
                  if (store[1] < store[0]) then
                    dec(store[0]);
                end;
              DOWN:
                if (store[1] < userlist.getLength() - 1) then begin
                  inc(store[1]);
                  if (store[1] - store[0] > 5) then
                    inc(store[0]);
                end;
            end;
            keyboard.reset;
          end else if keyboard.lastSpKey = ENTER then begin
            flag:= '';
            keyboard.reset;
          end;
        end;
        'createUser': begin
          case arrowL.y of
            19: begin //cancel and create
              case arrowL.x of
                6: begin // back
                  if keyboard.lastArrowKey <> NUL then begin
                    undrawArrow;
                    case keyboard.lastArrowKey of
                      RIGHT: setArrow(43, 19, 52, 19);
                      DOWN: setArrow(5, 10);
                      UP: setArrow(5, 16);
                    end;
                    keyboard.reset;
                  end
                  else if keyboard.lastSpKey = ENTER then begin
                    flag:= 'init';
                    undrawArrow();
                    setArrow(29, 24, 47, 24);
                    for x:= 0 to 3 do
                      freeAndNil(inputBoxes[x]);
                    keyboard.reset;
                  end;
                end;
                43: begin // done
                  if keyboard.lastArrowKey <> NUL then begin
                    undrawArrow;
                    case keyboard.lastArrowKey of
                      LEFT: setArrow(6, 19, 15, 19);
                      DOWN: setArrow(5, 10);
                      UP: setArrow(5, 16);
                    end;
                    keyboard.reset;
                  end else
                  if keyboard.lastSpKey = ENTER then begin
                    undrawArrow();
                    textColor(12);
                    if (inputBoxes[0].getContent <> '') then begin
                      console.fillBlank(16, 11, 26, 11);
                      if not (userlist.isExist(inputBoxes[0].getContent)) then begin
                        console.fillBlank(16, 11, 40, 11);
                        if (inputBoxes[1].getContent <> '') then begin
                          console.fillBlank(16, 13, 26, 13);
                          if (inputBoxes[2].getContent = inputBoxes[3].getContent) then begin
                            console.fillBlank(25, 17, 46, 17);
                            x:= userlist.addUser(
                              inputBoxes[0].getContent,
                              inputBoxes[1].getContent,
                              inputBoxes[2].getContent
                            );
                            if x = 0 then begin
                              userlist.exportList;
                              flag:= 'init';
                              setArrow(29, 24, 47, 24);
                              for y:= 0 to 3 do
                                freeAndNil(inputBoxes[y]);
                            end;
                          end else
                            console.writeXY('^ password mismatch', 25, 17);
                        end else
                          console.writeXY('^ required', 16, 13);
                      end else
                        console.writeXY('^ username has been used', 16, 11);
                    end else
                      console.writeXY('^ required', 16, 11);
                    textColor(7);
                    keyboard.reset;
                  end;
                end;
              end;
            end;
            10: begin
              inputBoxes[0].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(43, 19, 52, 19)
              else setArrow(5, 12);
              keyboard.reset;
            end;
            12: begin
              inputBoxes[1].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(5, 10)
              else setArrow(5, 14);
              keyboard.reset;
            end;
            14: begin
              inputBoxes[2].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(5, 12)
              else setArrow(5, 16);
              keyboard.reset;
            end;
            16: begin
              inputBoxes[3].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(5, 14)
              else setArrow(43, 19, 52, 19);
              keyboard.reset;
            end;
          end;
        end;
        'login': begin
          case arrowL.y of
            19: begin //cancel and create
              case arrowL.x of
                6: begin // back
                  if keyboard.lastArrowKey <> NUL then begin
                    undrawArrow;
                    case keyboard.lastArrowKey of
                      RIGHT: setArrow(44, 19, 52, 19);
                      DOWN: setArrow(5, 12);
                      UP: setArrow(6, 17, 25, 17);
                    end;
                    keyboard.reset;
                  end
                  else if keyboard.lastSpKey = ENTER then begin
                    flag:= 'init';
                    undrawArrow();
                    setArrow(61, 7, 69, 7);
                    freeAndNil(inputBoxes[0]);
                    freeAndNil(checkBoxes[0]);
                    keyboard.reset;
                  end;
                end;
                44: begin // done
                  if keyboard.lastArrowKey <> NUL then begin
                    undrawArrow;
                    case keyboard.lastArrowKey of
                      LEFT: setArrow(6, 19, 15, 19);
                      DOWN: setArrow(5, 12);
                      UP: setArrow(6, 17, 25, 17);
                    end;
                    keyboard.reset;
                  end else
                  if keyboard.lastSpKey = ENTER then begin
                    undrawArrow();
                    textColor(12);
                    user:= userlist.getUserAt(store[1]);
                    if (user.getPass =  userlist.encrypt(inputBoxes[0].getContent))
                    then begin
                      console.fillBlank(40, 12, 54, 12);
                      flag:= 'init';
                      setArrow(61, 7, 69, 7);
                      currentUser:= user;
                      freeAndNil(inputBoxes[0]);
                      freeAndNil(checkBoxes[0]);
                      store[3]:= 8;
                      store[2]:= 2;
                    end else
                      console.writeXY('Wrong Password', 40, 12);
                    textColor(7);
                    keyboard.reset;
                  end;
                end;
              end;
            end;
            17: begin // Forgot Password?
              if keyboard.lastArrowKey <> NUL then begin
                undrawArrow;
                case keyboard.lastArrowKey of
                  UP: setArrow(5, 13);
                  DOWN: setArrow(44, 19, 52, 19);
                end;
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER then begin
                freeAndNil(inputBoxes[0]);
                freeAndNil(checkBoxes[0]);
                undrawArrow;
                keyboard.reset;
                setArrow(6, 19, 15, 19);
                flag:= 'initFPass';
              end;
            end;
            13: begin // Show Password
              checkBoxes[0].routine;
              if keyboard.lastArrowKey <> NUL then begin
                undrawArrow;
                case keyboard.lastArrowKey of
                  UP: setArrow(5, 12);
                  DOWN: setArrow(6, 17, 25, 17);
                end;
                keyboard.reset;
              end;
            end;
            12: begin // password
              inputBoxes[0].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(44, 19, 52, 19)
              else setArrow(5, 13);
              keyboard.reset;
            end;
          end;
        end;
        'edit': begin
          case arrowL.y of
            19: begin //cancel and create
              case arrowL.x of
                6: begin // back
                  if keyboard.lastArrowKey <> NUL then begin
                    undrawArrow;
                    case keyboard.lastArrowKey of
                      RIGHT: setArrow(45, 19, 52, 19);
                      DOWN: setArrow(5, 10);
                      UP: setArrow(5, 16);
                    end;
                    keyboard.reset;
                  end
                  else if keyboard.lastSpKey = ENTER then begin
                    flag:= 'init';
                    undrawArrow();
                    setArrow(61, 11, 68, 11);
                    for x:= 0 to 3 do
                      freeAndNil(inputBoxes[x]);
                    keyboard.reset;
                  end;
                end;
                45: begin // done
                  if keyboard.lastArrowKey <> NUL then begin
                    undrawArrow;
                    case keyboard.lastArrowKey of
                      LEFT: setArrow(6, 19, 15, 19);
                      DOWN: setArrow(5, 10);
                      UP: setArrow(5, 16);
                    end;
                    keyboard.reset;
                  end else
                  if keyboard.lastSpKey = ENTER then begin
                    undrawArrow();
                    textColor(12);
                    y:= 0;
                    if (inputBoxes[0].getContent <> '') then begin
                      if not (userlist.isExist(inputBoxes[0].getContent)) then begin
                        console.fillBlank(16, 11, 40, 11);
                        x:= userlist.editUsername(
                          currentUser.username,
                          inputBoxes[0].getContent
                        );
                        y:= 1;
                      end else
                        console.writeXY('^ username has been used', 16, 11);
                    end;
                    if (inputBoxes[1].getContent <> '') then begin
                      x:= userlist.editNickname(
                        currentUser.username,
                        inputBoxes[1].getContent
                      );
                      y:= 1;
                    end;
                    if (inputBoxes[2].getContent <> '') then begin
                      if (inputBoxes[2].getContent = inputBoxes[3].getContent) then begin
                        console.fillBlank(25, 17, 46, 17);
                        x:= userlist.editPassword(
                          currentUser.username,
                          inputBoxes[2].getContent
                        );
                        y:= 1;
                      end else
                        console.writeXY('^ password mismatch', 25, 17);
                    end;
                    if (y = 1) then begin
                      store[2]:= 7;
                      store[3]:= 8;
                      userlist.exportList;
                    end;
                    flag:= 'init';
                    setArrow(61, 11, 68, 11);
                    textColor(7);
                    for x:= 0 to 3 do
                      freeAndNil(inputBoxes[x]);
                    keyboard.reset;
                  end;
                end;
              end;
            end;
            10: begin
              inputBoxes[0].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(45, 19, 52, 19)
              else setArrow(5, 12);
              keyboard.reset;
            end;
            12: begin
              inputBoxes[1].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(5, 10)
              else setArrow(5, 14);
              keyboard.reset;
            end;
            14: begin
              inputBoxes[2].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(5, 12)
              else setArrow(5, 16);
              keyboard.reset;
            end;
            16: begin
              inputBoxes[3].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(5, 14)
              else setArrow(45, 19, 52, 19);
              keyboard.reset;
            end;
          end;
        end;
        'delete': begin
          case arrowL.x of
            22: begin
              if keyboard.lastArrowKey = RIGHT then begin
                undrawArrow;
                setArrow(31, 15, 37, 15);
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER then begin
                undrawArrow;
                setArrow(61, 15, 70, 15);
                keyboard.reset;
                flag:= 'init';
              end;
            end;
            31: begin
              if keyboard.lastArrowKey = LEFT then begin
                undrawArrow;
                setArrow(22, 15, 27, 15);
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER then begin
                undrawArrow;
                setArrow(61, 15, 70, 15);
                keyboard.reset;
                x:= userlist.deleteUser(currentUser.username);
                if (x = 0) then begin
                  store[2]:= 6;
                  store[3]:= 8;
                  currentUser:= userlist.getUser('');
                  userlist.exportList;
                end else begin
                  store[2]:= 5;
                  store[3]:= 8;
                end;
                flag:= 'init';
              end;
            end;
          end;
        end;
        'fPass': begin
          case arrowL.y of
            19: begin //cancel and create
              case arrowL.x of
                6: begin // back
                  if keyboard.lastArrowKey <> NUL then begin
                    undrawArrow;
                    case keyboard.lastArrowKey of
                      RIGHT: setArrow(45, 19, 52, 19);
                      DOWN: setArrow(5, 12);
                      UP: setArrow(5, 16);
                    end;
                    keyboard.reset;
                  end
                  else if keyboard.lastSpKey = ENTER then begin
                    flag:= 'initLogin';
                    undrawArrow();
                    setArrow(6, 19, 15, 19);
                    for x:= 1 to 3 do
                      freeAndNil(inputBoxes[x]);
                    keyboard.reset;
                  end;
                end;
                45: begin // done
                  if keyboard.lastArrowKey <> NUL then begin
                    undrawArrow;
                    case keyboard.lastArrowKey of
                      LEFT: setArrow(6, 19, 15, 19);
                      DOWN: setArrow(5, 12);
                      UP: setArrow(5, 16);
                    end;
                    keyboard.reset;
                  end else
                  if keyboard.lastSpKey = ENTER then begin
                    undrawArrow();
                    textColor(12);
                    y:= 0;
                    if (inputBoxes[1].getContent =
                      userlist.getUserAt(store[1]).nickname)
                    then begin
                      if (inputBoxes[2].getContent = inputBoxes[3].getContent)
                      then begin
                        console.fillBlank(25, 17, 46, 17);
                        x:= userlist.forgotPassword(
                          userlist.getUserAt(store[1]).username,
                          inputBoxes[2].getContent
                        );
                        userlist.exportList;
                      end else
                        console.writeXY('^ password mismatch', 25, 17);
                    end;
                    flag:= 'initLogin';
                    setArrow(61, 11, 68, 11);
                    textColor(7);
                    for x:= 1 to 3 do
                      freeAndNil(inputBoxes[x]);
                    keyboard.reset;
                  end;
                end;
              end;
            end;
            10: begin
              inputBoxes[0].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(45, 19, 52, 19)
              else setArrow(5, 12);
              keyboard.reset;
            end;
            12: begin
              inputBoxes[1].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(45, 19, 52, 19)
              else setArrow(5, 14);
              keyboard.reset;
            end;
            14: begin
              inputBoxes[2].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(5, 12)
              else setArrow(5, 16);
              keyboard.reset;
            end;
            16: begin
              inputBoxes[3].routine;
              if keyboard.lastArrowKey = UP then
                setArrow(5, 14)
              else setArrow(45, 19, 52, 19);
              keyboard.reset;
            end;
          end;
        end;
      end;
    end;
    pMainMenu: begin
      case ArrowL.y of
        6: begin //Play
          if keyboard.lastArrowKey <> NUL then begin
            undrawArrow;
            case keyboard.lastArrowKey of
              UP: setArrow(28, 24, 35, 24);
              DOWN: setArrow(18, 12, 32, 12);
              RIGHT: if store[0] < 6 then inc(store[0]);
              LEFT: if store[0] > 3 then dec(store[0]);
            end;
            keyboard.reset;
          end else
          if keyboard.lastSpKey = ENTER then begin
            undrawArrow();
            keyboard.reset();
            changePage:= true;
            prevPage:= currentPage;
            boardSize:= store[0];
            currentPage:= pPlayGame;
          end;
        end;
        12: begin //Change User
          if keyboard.lastArrowKey <> NUL then begin
            undrawArrow;
            case keyboard.lastArrowKey of
              UP: setArrow(13, 6);
              DOWN: setArrow(23, 18, 36, 18);
            end;
            keyboard.reset;
          end else
          if keyboard.lastSpKey= ENTER then begin
            undrawArrow;
            keyboard.reset;
            changePage:= true;
            prevPage:= currentPage;
            currentPage:= pLogin;
          end;
        end;
        18: begin //High Score
          if keyboard.lastArrowKey <> NUL then begin
            undrawArrow;
            case keyboard.lastArrowKey of
              UP: setArrow(18, 12, 32, 12);
              DOWN: setArrow(28, 24, 35, 24);
            end;
            keyboard.reset;
          end else
          if keyboard.lastSpKey = ENTER then begin
            undrawArrow;
            keyboard.reset;
            changePage:= true;
            currentPage:= pHighScore;
          end;
        end;
        24: begin //Exit
          if keyboard.lastArrowKey <> NUL then begin
            undrawArrow;
            case keyboard.lastArrowKey of
              UP: setArrow(23, 18, 36, 18);
              DOWN: setArrow(13,6);
            end;
            keyboard.reset;
          end else
          if keyboard.lastSpKey = ENTER then begin
            undrawArrow;
            keyboard.reset;
            changePage:= true;
            exitState:= true;
            gotoXY(console.width, console.height);
          end;
        end;
      end;
    end;
    pPlayGame: begin
      case flag of
        'play': begin
          if keyboard.lastArrowKey <> NUL then begin
            game.board.shift(keyboard.lastArrowKey);
            keyboard.reset();
          end
          else if keyboard.lastKey <> 0 then begin
            case char(keyboard.lastKey) of
              'p': begin
                flag:= 'initPause';
                delayTime:= 200;
              end;
              'z': begin
                if store[0] > 0 then
                  flag:= 'undo';
                console.writeXY('z', 2, 4);
              end;
            end;
            keyboard.reset();
          end;
        end;
        'pause': begin
          x:= 33;
          y:= 12;
          case arrowL.y of
            12: begin // Resume
              if keyboard.lastArrowKey = DOWN then begin
                undrawArrow;
                setArrow(x, y+2, x+10, y+2);
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER  then begin
                delayTime:= 0;
                flag:= 'init';
              end;
            end;
            12+2: begin // Restart
              if keyboard.lastArrowKey <> NUL then begin
                undrawArrow;
                case keyboard.lastArrowKey of
                  UP: setArrow(x, y, x+9, y);
                  DOWN: setArrow(x+1, y+4, x+8, y+4);
                end;
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER then begin
                undrawArrow;
                keyboard.reset;
                freeAndNil(game);
                changePage:= true;
              end;
            end;
            12+4: begin // Exit
              if keyboard.lastArrowKey = UP then begin
                undrawArrow;
                setArrow(x, y+2, x+10, y+2);
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER then begin
                undrawArrow;
                keyboard.reset;
                freeAndNil(game);
                changePage:= true;
                currentPage:= pMainMenu;
              end;
            end;
          end;
        end;
        'gameover': begin
          x:= 33;
          y:= 12;
          case arrowL.y of
            12: begin // Undo
              if keyboard.lastArrowKey = DOWN then begin
                undrawArrow;
                setArrow(x, y+2, x+10, y+2);
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER  then begin
                delayTime:= 0;
                flag:= 'undo';
              end;
            end;
            12+2: begin // Restart
              if keyboard.lastArrowKey <> NUL then begin
                undrawArrow;
                case keyboard.lastArrowKey of
                  UP: setArrow(x+1, y, x+8, y);
                  DOWN: setArrow(x+1, y+4, x+8, y+4);
                end;
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER then begin
                undrawArrow;
                keyboard.reset;
                scorelist.checkin(currentUser, game.board.getScore);
                scorelist.exportList;
                freeAndNil(game);
                changePage:= true;
              end;
            end;
            12+4: begin // Exit
              if keyboard.lastArrowKey = UP then begin
                undrawArrow;
                setArrow(x, y+2, x+10, y+2);
                keyboard.reset;
              end else
              if keyboard.lastSpKey = ENTER then begin
                undrawArrow;
                keyboard.reset;
                scorelist.checkin(currentUser, game.board.getScore);
                scorelist.exportList;
                freeAndNil(scorelist);
                freeAndNil(game);
                changePage:= true;
                currentPage:= pMainMenu;
              end;
            end;
          end;
        end;
      end;
    end;
    pHighscore: begin
      case arrowL.y of
        27: begin // Back
          if keyboard.lastArrowKey = UP then begin
            undrawArrow;
            keyboard.reset;
            setArrow(1, 25);
          end else
          if keyboard.lastSpKey = ENTER then begin
            freeAndNil(scorelist);
            undrawArrow;
            keyboard.reset;
            changePage:= true;
            currentPage:= pMainMenu;
          end;
        end;
        25: begin //Select size
          if keyboard.lastArrowKey <> NUL then begin
            if (keyboard.lastArrowKey = LEFT) and
            (store[0] > 3) or
            (keyboard.lastArrowKey = RIGHT) and
            (store[0] < 6)
            then begin
              flag:= 'initChange';
              console.writeAlignMiddle(
                'Loading...',
                console.width div 2,
                console.height div 2
              );
            end;
            case keyboard.lastArrowKey of
              LEFT: if store[0] > 3 then dec(store[0]);
              RIGHT: if store[0] < 6 then inc(store[0]);
              DOWN: setArrow(4, 27, 11, 27);
            end;
            keyboard.reset;
          end;
        end;
      end;
    end;
  end;
end;

constructor TMainSystem.create;
var i: byte;
begin
  currentPage:= pStartPage;
  delaytime:= 200;
  keyboard:= TKeyboardListener.create;
  userlist:= TUserList.create;
  currentUser:= userlist.getUser('Jordi');
end;

destructor TMainSystem.destroy;
var i: byte;
begin
  inherited;
  freeAndNil(scoreList);
  freeAndNil(userList);
  freeAndNil(currentUser);
  freeAndNil(game);
  freeAndNil(keyboard);
  for i:= 0 to 4 do
    freeAndNil(inputBoxes[i]);
  for i:= 0 to 1 do
    freeAndNil(checkBoxes[i]);
end;

procedure TMainSystem.routine;
var
  exitState, changePage, exitProgram: boolean;
  flag: string;
  store: arrayByte;
begin
  cursoroff;
  exitProgram:= false;
  repeat
    exitState:= false;
    repeat
      framecount:= 0;
      changePage:= false;
      flag:= '';
      clrscr;
      setup(changePage, exitState, flag, store);
      drawPage();
      repeat
        inc(framecount);
        update(changePage, exitState, flag, store);
        render(flag, store);
        listen(changePage, exitState, flag, store);
        sleep(delaytime);
      until changePage;
    until exitState;
    exitProgram:= true;
  until exitProgram;
  cursoron;
end;

{ TKeyboardListener }

constructor TKeyboardListener.create;
begin
  reset();
  inherited;
end;

procedure TKeyboardListener.listen();
var c: char;
begin
  repeat
  until keyPressed;
  c:= readkey();
  if (byte(c) = 0) then
  begin
    c:= readKey();
    case byte(c) of
      $48: lastArrowKey:= UP;
      $4B: lastArrowKey:= LEFT;
      $4D: lastArrowKey:= RIGHT;
      $50: lastArrowKey:= DOWN;
      $47: lastSpKey:= HOME;
      $4F: lastSpKey:= EN;
      $53: lastSpKey:= DEL;
    end;
  end else begin
    lastKey:= byte(c);
    if not (lastKey in [33..126]) then begin
      case lastKey of
        13: lastSpKey:= ENTER;
        8: lastSpKey:= BACKSPACE;
        32: lastSpKey:= SPACE;
      end;
      lastKey:= 0;
    end;
  end;
end;

procedure TKeyboardListener.reset();
begin
  lastArrowKey:= NUL;
  lastSpKey:= NULL;
  lastKey:= 0;
end;

{ TGameSystem }

procedure TGameSystem.pour(arr: arrayByte; score: longInt);
var
  len, i: byte;
  hand: RHistoryModel;
begin
  len:= length(historyPool);
  if (len < maxUndo) then
  begin
    setLength(historyPool, len + 1);
    inc(len);
  end else
  begin
    i:= 0;
    while (i < len-1) do
    begin
      historyPool[i]:= historyPool[i+1];
      i:= i + 1;
    end;
  end;
  hand.table:= arr;
  hand.score:= score;
  historyPool[len-1]:= hand;
end;

function TGameSystem.slurp(): RHistoryModel;
var
  len: byte;
begin
  len:= length(historyPool);
  slurp:= historyPool[len-1];
  setLength(historyPool, len-1);
end;

procedure TGameSystem.drainPool();
begin
  setLength(historyPool, 0);
end;

procedure TGameSystem.undo();
var
  len: byte;
  hand: RHistoryModel;
begin
  len:= length(historyPool);
  if len > 0 then
  begin
    hand:= slurp();
    board.setTable(hand.table);
    board.setScore(hand.score);
  end;
end;

procedure TGameSystem.restart();
begin
  freeAndNil(board);
  routine();
end;

procedure TGameSystem.gameOver();
var
  x, y: integer;
begin
  x:= console.width div 2 - 9;
  y:= console.height;
  console.writeXY('Pick your choice:', x, y - 5);
  x:= x + 2;
  console.writexy('[r]estart', x, y - 4);
  console.writexy('[u]ndo', x, y - 3);
  console.writexy('[e]xit', x, y - 2);
  repeat
    keyboard.listen();
  until (char(keyboard.lastKey) in ['r', 'e', 'u', 'R', 'E', 'U']);

  console.writexy('         ', x, y - 4);
  console.writexy('      ', x, y - 3);
  console.writexy('      ', x, y - 2);
  x:= x - 2;
  console.writeXY('                 ', x, y - 5);

  case char(keyboard.lastKey) of
    'r': restart();
    'u': begin
      undo();
      play();
    end;
  end;
end;

function TGameSystem.isDiff(const arr1, arr2: arrayByte): boolean;
var
  i, len: byte;
  ident: boolean;
begin
  ident:= true;
  len:= size*size;
  i:= 0;
  while ident and (i < len) do
  begin
    if (arr1[i] <> arr2[i]) then
      ident:= false;
    inc(i);
  end;
  isDiff:= not ident;
end;

procedure TGameSystem.update(var exitState: boolean; var flag: string);
var
  tmpBoard: arrayByte;
  tmpScore: longInt;
begin
  if (flag = 'restart') then
    if (char(keyboard.lastKey) in ['y','Y']) then
    begin
      flag:= 'restarty';
      exitState:= true;
    end else
    if (keyboard.lastKey <> 0) then
      flag:= 'restartn';
  if (flag = 'gameover') then
    if(char(keyboard.lastKey) in ['r','R']) then
    begin
      flag:= 'restarty';
      exitState:= true;
    end else
    if (char(keyboard.lastKey) in ['u','U']) then
    begin
      flag:= '0';
      undo();
    end else
    if (char(keyboard.lastKey) in ['e', 'E']) then
      exitState:= true;
  if (flag = '0') and (char(keyboard.lastKey) in ['R', 'r']) then
    flag:= 'restart'
  else if ( char(keyboard.lastKey) in ['z', 'Z']) then
    undo();
  setLength(tmpBoard, size*size);
  board.copyTo(tmpBoard);
  tmpScore:= board.getScore();
  if (keyboard.lastArrowKey <> NUL) then
    board.shift(keyboard.lastArrowKey);
  if isDiff(board.getTable(), tmpBoard) then
  begin
    pour(tmpBoard, tmpScore);
    if not board.noMoveLeft() then
      board.insertRandom;
  end;
  if board.noMoveLeft() then
    flag:= 'gameover';
end;

procedure TGameSystem.render(var flag: string);
begin
  cursoroff;
  if (flag = 'restart') then
  begin
    console.writeAlignMiddle('Do you want to restart?', console.width div 2, console.height - 5);
    console.writeAlignMiddle('[y]es or [n]o', console.width div 2, console.height - 4);
  end else
  if (flag = 'restartn') then
  begin
    flag:= '0';
    console.writeAlignMiddle('                       ', console.width div 2, console.height - 5);
    console.writeAlignMiddle('             ', console.width div 2, console.height - 4);
    board.drawFrame();
  end else
  begin
    board.render();
    console.writeXY('Scores:', console.width - 14, 2);
    console.writeXY('       ', console.width - 7, 2);
    console.writeNumRight(board.getScore(), console.width, 2);
  end;
  if (flag = 'gameover') then
  begin
    console.writeXY('Pick your choice:', console.width div 2 - 8, console.height - 5);
    console.writexy('[r]estart', console.width div 2 - 6, console.height - 4);
    console.writexy('[u]ndo', console.width div 2 - 6, console.height - 3);
    console.writexy('[e]xit', console.width div 2 - 6, console.height - 2);
  end;
  cursoron;
  gotoXY(console.width, console.height);
end;

procedure TGameSystem.listen();
begin
  //if KeyPressed then
    keyboard.reset;
    keyboard.listen;
end;

constructor TGameSystem.create(const siz: byte);
begin
  size:= siz;
  maxUndo:= 3;
  //keyboard:= TKeyboardListener.create;
  setup();
end;

destructor TGameSystem.destroy();
begin
  freeAndNil(board);
  //freeAndNil(keyboard);
  inherited;
end;

procedure TGameSystem.setup();
var
  pboard: Point;
  scl: byte;
begin
  case size of
    3: scl:= 3;
    4..5: scl:= 2;
    else scl:= 1;
  end;
  drainPool();
  pboard.x:= console.width div 2 - 2*size*scl;
  pboard.y:= 14-scl*2-size;
  board:= TBoard.create(pboard, size, scl);
  //keyboard.reset();
  console.reset();
end;

procedure TGameSystem.play();
var
  exitState: boolean;
  flag: string;
begin
  board.drawFrame;
  board.insertRandom;
  pour(board.getTable(), board.getScore());
  exitState:= false;
  flag:= '0';
  repeat
    update(exitState, flag);
    render(flag);
    listen();
  until exitState;
  if (flag = 'restarty') then
    restart();
end;

procedure TGameSystem.routine();
begin
  setup();
  play();
  gameOver();
end;

{ TScoreList }

function TScoreList.toSModel(user: TUser; score: longint): RScoreModel;
var
  sm: RScoreModel;
begin
  sm.username:= user.username;
  //sm.nickname:= user.nickname;
  sm.score:= score;
  toSModel:= sm;
end;

function TScoreList.toSModel(const username{, nickname}: String; score: longint
  ): RScoreModel;
var
  sm: RScoreModel;
begin
  sm.username:= username;
  //sm.nickname:= nickname;
  sm.score:= score;
  toSModel:= sm;
end;

procedure TScoreList.sort;
var
  i, j, iMax, len: byte;
  tmp: RScoreModel;
begin
  len:= length(scoresList);
  if(len > 0) then
  begin
    for i:= 0 to len-2 do
    begin
      iMax:= i;
      tmp:= scoresList[i];
      for j:= i + i to len - 1 do
      begin
        if(scoresList[j].score > scoresList[iMax].score) then
          iMax:= j;
      end;
      scoresList[i]:= scoresList[iMax];
      scoresList[iMax]:= tmp;
    end;
  end;
end;

procedure TScoreList.push(sModel: RScoreModel);
var
  len: byte;
begin
  len:= length(scoresList);
  if(len < MaxTopScore) then
  begin
    setLength(scoresList, len+1);
    scoresList[len]:= sModel;
  end;
end;

procedure TScoreList.insert(sModel: RScoreModel; index: byte);
var
  i, len: byte;
begin
  len:= length(scoresList);
  if (index < len) then
  begin
    if(len < MaxTopScore) then
    begin
      setLength(scoresList, len+1);
      for i:= len downto index + 1 do
        scoresList[i]:= scoresList[i-1];
      scoresList[index]:= sModel;
    end
    else begin
      for i:= len-1 downto index + 1 do
        scoresList[i]:= scoresList[i-1];
      scoresList[index]:= sModel
    end;
  end;
end;

procedure TScoreList.pop;
var len: byte;
begin
  len:= length(scoresList);
  setLength(scoresList, len-1);
end;

procedure TScoreList.checkin(user: TUser; score: longint);
var
  i, len: byte;
  added: boolean;
  sm: RScoreModel;
begin
  len:= length(scoresList);
  sm:= toSModel(user, score);
  if(len = 0) then
  begin
    push(sm);
  end
  else begin
    added:= false;
    for i:= 0 to len-1 do
    begin
      if(score > scoresList[i].score) then
      begin
        insert(sm, i);
        added:= true;
        break;
      end;
    end;
    if not added and (len < MaxTopScore) then
      push(sm);
  end;
end;

constructor TScoreList.Create(const fname: String);
var
  f: file of RScoreModel;
  score: RScoreModel;
begin
  setLength(scoresList, 0);
  assign(f, fname);
  filename:= fname;
  try
    reset(f);
  except
    rewrite(f);
    reset(f);
    //writeln('Please restart this program');
  end;
  while not eof(f) do
  begin
    read(f, score);
    push(score);
  end;
  close(f);
end;

function TScoreList.getAt(id: byte): rScoreModel;
begin
  getAt:= scoresList[id];
end;

function TScoreList.getLength: byte;
begin
  getLength:= length(scoresList);
end;

procedure TScoreList.displayList;
var
  i, len: byte;
begin
  len:= length(scoresList);
  if(len > 0) then
  begin
    for i:= 0 to len-1 do
    begin
      if((i+1) div 10 = 0) then write(' ');
      writeln(i+1,'# ',scoresList[i].username,' '{,scoresList[i].nickname,' '},scoresList[i].score);
    end;
  end;
end;

procedure TScoreList.deleteAll;
begin
  setLength(scoresList, 0);
end;

procedure TScoreList.deleteAt(index: byte);
var
  i, len: byte;
begin
  len:= length(scoresList);
  if (index < len) then
  begin
    if (index < len - 1) then
    begin
      for i:= index to len-2 do
      begin
        scoresList[i]:= scoresList[i + 1];
      end;
    end;
    pop;
  end
  //else
  //  writeln('Conflict 409: ','Index out of bound');
end;

procedure TScoreList.exportList;
var
  f: file of RScoreModel;
  sModel: RScoreModel;
  i, len: byte;
begin
  len:= length(scoresList);
  assign(f, filename);
  rewrite(f);
  i:= 0;
  while (i < len) do
  begin
    write(f, scoresList[i]);
    inc(i);
  end;
  close(f);
end;

{ TUser }

constructor TUser.create(const uname, nname, pass: string);
begin
  username:= uname;
  nickname:= nname;
  password:= pass;
  totalScore:= 0;
end;

constructor TUser.create(const rawUser: RUser);
begin
  username:= rawUser.username;
  nickname:= rawUser.nickname;
  password:= rawUser.password;
  totalScore:= rawUser.totalScore;
end;

constructor TUser.create(const uname, nname, pass: string; score: longint);
begin
  username:= uname;
  nickname:= nname;
  password:= pass;
  totalScore:= score;
end;

function TUser.getScore: longint;
begin
  getScore:= totalScore;
end;

procedure TUser.setScore(score: longint);
begin
  totalScore:= score;
end;

procedure TUser.addScore(num: longint);
begin
  totalScore:= totalScore + num;
end;

function TUser.getRaw: RUser;
Var
  rawUser: RUser;
begin
  rawUser.username:= username;
  rawUser.nickname:= nickname;
  rawUser.password:= password;
  rawUser.totalScore:= totalScore;
  getRaw:= rawUser;
end;

function TUser.getPass(): string;
begin
  getPass:= password;
end;

procedure TUser.setPass(const str: string);
begin
  password:= str;
end;

{ TUserList }

procedure TUserList.push(const user: TUser);
var
  len: integer;
begin
  len:= length(usersList);
  setLength(usersList, len+1);
  usersList[len]:= user;
end;

procedure TUserList.pop;
begin
  freeAndNil(usersList[length(usersList)-1]);
  setLength(usersList, length(usersList)-1);
end;

function TUserList.encrypt(const str: string): string;
var
  buff: string;
  c: char;
  x: byte;
begin
  buff:= '';
  for c in str do
  begin
    x:= byte(c) + 7;
    case c of
      'a'..'z':
        if x > 122 then
          x:= x - 122 + 96;
      'A'..'Z':
        if x > 90 then
          x:= x - 90 + 64;
      '0'..'9':
        if x > 57 then
          x:= x - 57 + 47;
    end;
    buff:= buff + char(x);
  end;
  encrypt:= buff;
end;

function TUserList.decrypt(const str: string): string;
var
  buff: string;
  c: char;
  x: byte;
begin
  buff:= '';
  for c in str do
  begin
    x:= byte(c) - 7;
    case c of
      'a'..'z':
        if x < 97 then
          x:= x + 122 - 96;
      'A'..'Z':
        if x < 64 then
          x:= x + 90 - 64;
      '0'..'9':
        if x < 48 then
          x:= x + 57 - 47;
    end;
    buff:= buff + char(x);
  end;
  decrypt:= buff;
end;

function TUserList.isExist(const username: string): boolean;
var
  len, i: integer;
  found: boolean;
begin
  found:= false;
  len:= length(usersList);
  i:= 0;
  while (i < len) AND not found do
  begin
    if(usersList[i].username = username) then
      found:= true;
    inc(i);
  end;
  isExist:= found;
end;

constructor TUserList.create;
var
  f: file of RUser;
  user, guest: TUser;
  rawUser: RUser;
begin
  setLength(usersList, 0);
  assign(f, UserListFName);
  guest:= TUser.Create('guest', 'Guest', '');
  push(guest);
  try
    reset(f);
  except
    rewrite(f);
    reset(f);
    //writeln('Please restart program');
  end;
  while not eof(f) do
  begin
    read(f, rawUser);
    user:= TUser.Create(rawUser);
    push(user);
  end;
  close(f);
end;

destructor TUserList.destroy;
begin
  deleteAll;
end;

function TUserList.getUser(const username: string): TUser;
var
  i: integer;
  found: boolean;
begin
  found:= false;
  for i:= 1 to length(usersList)-1 do
  begin
    if (usersList[i].username = username) then
    begin
      found:= true;
      break;
    end;
  end;
  if found then
    getUser:= usersList[i]
  else
  begin
    getUser:= usersList[0];
    //writeln('Error 404: ', 'Not found');
  end;
end;

function TUserList.getLength(): integer;
begin
  getLength:= length(usersList);
end;

function TUserList.getUserAt(i: byte): TUser;
begin
  if i < length(usersList) then
    getUserAt:= usersList[i]
  else
    getUserAt:= usersList[0];
end;

function TUserList.editUsername(const username, newUname: string): byte;
var
  user: TUser;
  return: byte;
begin
  return:= 1; //Not OK
  if isExist(username) then
  begin
    user:= getUser(username);
    if not isExist(newUname) then
    begin
      user.username:= newUname;
      return:= 0;
    end;
  end;
  editUsername:= return;
  //else writeln('Error 404: ','Not found');
end;

function TUserList.editNickname(const username, newNickname: string): byte;
var
  user: TUser;
  return: byte;
begin
  return:= 1; //Not OK
  if isExist(username) then
  begin
    user:= getUser(username);
    user.nickname:= newNickname;
    return:= 0;
  end;
  editNickname:= return;
end;

function TUserList.editPassword(const username, newPass: string): byte;
var
  user: TUser;
  return: byte;
begin
  return:= 1; //Not OK
  if isExist(username) then
  begin
    user:= getUser(username);
    user.setPass(encrypt(newPass));
    return:= 0;
  end;
  editPassword:= return;
end;

function TUserList.forgotPassword(const username, newPass: string): byte;
var
  user: TUser;
  return: byte;
begin
  return:= 1; //Not OK
  if isExist(username) then
  begin
    user:= getUser(username);
    user.setPass(encrypt(newPass));
    return:= 0;
  end;
  forgotPassword:= return;
end;

function TUserList.addUser(const username, nickname, password: string): byte;
var
  user: TUser;
  return: byte;
begin
  return:= 1;
  if not isExist(username) then
  begin
    user:= TUser.Create(username, nickname, encrypt(password));
    push(user);
    return:= 0;
  end;
  addUser:= return;
  //else writeln('Conflict 409: ','username already exist');
end;

function TUserList.deleteUser(const username: string): byte;
var
  i, j, len: integer;
  found: boolean;
  return: byte;
begin
  return:= 1; //Not OK
  found:= false;
  len:= length(usersList);
  for i:= 1 to len-1 do
    if (usersList[i].username = username) then
    begin
      freeAndNil(usersList[i]);
      for j:= i to len-2 do
        usersList[j]:= usersList[j+1];
      setLength(usersList, len-1);
      found:= true;
      return:= 0;
      break;
    end;
  deleteUser:= return;
  //if not found then write('Error 404: ','User not found!');
end;

procedure TUserList.deleteAll;
var
  i, len : integer;
  user: TUser;
begin
  len:= length(usersList);
  for i:= 1 to len-1 do
  begin
    freeAndNil(usersList[i]);
  end;
  setLength(usersList, 1);
end;

procedure TUserList.dispList;
var
  i: integer;
begin
  for i:= 0 to length(usersList)-1 do
  begin
    writeln('Username #',i,': ',usersList[i].username);
    writeln('Nickname #',i,': ',usersList[i].nickname);
    writeln('TotScore #',i,': ',usersList[i].getScore, #10);
  end;
end;

procedure TUserList.exportList;
var
  i, len: integer;
  f: file of RUser;
begin
  len:= length(usersList);
  Assign(f, UserListFName);
  rewrite(f);
  i:= 1;
  while i < len do
  begin
    write(f, usersList[i].getRaw);
    inc(i);
  end;
  closeFile(f);
end;

{ TBoard }

constructor TBoard.create(const p: Point; siz: byte);
begin
  pos:= p;
  size:= siz;
  len:= size*size;
  setLength(table, len);
  scale:= 1;
  setVal(64);
  score:= 0;
  count:= 0;
end;

constructor TBoard.create(const p: Point; siz, scl: byte);
begin
  create(p, siz);
  scale:= scl;
end;

procedure TBoard.setSize(const siz: byte);
begin
  size:= siz;
  len:= size*size;
end;

function TBoard.getTable(): arrayByte;
begin
  getTable:= table;
end;

procedure TBoard.setPos(const p: Point);
begin
  pos:= p;
end;

function TBoard.getPos(): Point;
begin
  getPos:= pos;
end;

procedure TBoard.setVal(const val: byte);
var
  i: integer;
begin
  for i:= 0 to len-1 do
    table[i]:= val;
  if(val <> 64) then
    count:= len;
end;

procedure TBoard.setVal(const index: byte; const val: byte);
begin
  table[index]:= val;
  if(val <> 64) then
    count:= count + 1;
end;

procedure TBoard.setTable(tb: arrayByte);
var i: byte;
begin
  if (len = length(tb)) then
    for i:= 0 to len - 1 do
      table[i]:= tb[i];
end;

procedure TBoard.insertRandom();
var
  x: byte;
begin
  if (count < len) then
  begin
    repeat
      x:= random(len);
    until (table[x] = 64);
    if(random() < 0.9) then
      setVal(x, 65)
    else
      setVal(x, 66);
  end;
end;

function TBoard.getVal(const index: byte): byte;
begin
  getVal:= table[index];
end;

procedure TBoard.drawFrame();
var
  i, j: byte;
begin
  for j:= 0 to 2*size*scale do
  begin
    for i:= 0 to 2*size*scale do
    begin
      gotoxy(pos.x + 2*i, pos.y + j);
      //if(i mod (2*scale) = 0) OR (j mod (2*scale) = 0) then
      //  write('#');
      if(i mod (2*scale) = 0) and (j mod (2*scale) = 0) then
        write('+')
      else if(i mod (2*scale) = 0) then
        write('|')
      else if(j mod (2*scale) = 0) then
        write('-');
    end;
  end;
end;

procedure TBoard.render();
var
  i, k, c: byte;
  xx, yy: integer;
  buff: string;
begin
  highVideo;
  c:= 0;
  buff:= '';
  k:= 4*(scale) - 2;
  for i:= 0 to k do
  begin
    buff:= buff+' ';
  end;
  for k:= 0 to len-1 do
  begin
    case (table[k]) of
      65: c:= 1;
      66: c:= 2;
      67: c:= 3;
      68: c:= 4;
      69: c:= 5;
      70: c:= 5;
      71: c:= 6;
      72: c:= 6;
      73: c:= 6;
      74: begin
        c:= 7;
        TextColor(0);
      end;
      75: begin
        c:= 7;
        textColor(0);
      end;
      76: c:= 10;
      77: c:= 10;
      78: c:= 11;
      else c:= 0;
    end;
    TextBackground(c);
    xx:= pos.x + (k mod size)*4*scale + 1;
    yy:= pos.y + (k div size)*2*scale + 1;
    for i:= 0 to 2*(scale-1) do
    begin
      gotoXY(xx, yy + i);
      write(buff);
    end;
    xx:= pos.x + (k mod size)*4*scale + scale*2;
    yy:= pos.y + (k div size)*2*scale + scale;
    gotoXY(xx, yy);
    if table[k] = 64 then
      write(' ')
    else
      write(char(table[k]));
    normVideo;
    highVideo;
  end;
  normVideo;
end;

procedure TBoard.shift(dir: EArrow);
var
  i, j: byte;
  empId, befId: integer;
  bef: byte;
begin
  case (dir) of
    LEFT: begin
      for j:= 0 to size-1 do
      begin
        empId:= -1;
        befId:= -1;
        for i:= 0 to size-1 do
        begin
          if (table[j*size + i] <> 64) then//table[i] tidak kosong
            if (befId = -1) then //belum ada nilai sebelumnya
            begin
              befId:= i;
              bef:= table[j*size + i];
              if (empId <> -1) then //sebelumnya pernah kosong
              begin
                table[j*size + empId]:= bef;
                table[j*size + i]:= 64;
                befId:= empId;
                empId:= empId + 1;
              end;
            end
            else if(bef = table[j*size + i]) then //nilai sebelumnya sama dengan table[i]
            begin
              table[j*size + befId]:= table[j*size + befId] + 1;
              addScore(2**(table[j*size + befId] - 64));
              table[j*size + i]:= 64;
              count:= count - 1;
              befId:= -1;
//              bef:= table[j*size + befId];
            end
            else //jika tidak sama dengan nilai sebelumnya
            begin
              if (empId <> -1) then
              begin
                table[j*size + empId]:= table[j*size + i];
                table[j*size + i]:= 64;
                empId:= empId + 1;
              end;
              befId:= befId + 1;
              bef:= table[j*size + befId];
            end;
          if (table[j*size + i] = 64) and (empId = -1) then //table[i] kosong
              empId:= i;
        end;
      end;
    end;

    RIGHT: begin
      for j:= 0 to size-1 do
      begin
        empId:= -1;
        befId:= -1;
        for i:= size-1 downto 0 do
        begin
          if (table[j*size + i] <> 64) then//table[i] tidak kosong
            if (befId = -1) then //belum ada nilai sebelumnya
            begin
              befId:= i;
              bef:= table[j*size + i];
              if (empId <> -1) then //sebelumnya pernah kosong
              begin
                table[j*size + empId]:= bef;
                table[j*size + i]:= 64;
                befId:= empId;
                empId:= empId - 1;
              end;
            end
            else if(bef = table[j*size + i]) then //nilai sebelumnya sama dengan table[i]
            begin
              table[j*size + befId]:= table[j*size + befId] + 1;
              addScore(2**(table[j*size + befId] - 64));
              table[j*size + i]:= 64;
              count:= count - 1;
              befId:= -1;
              //bef:= table[j*size + befId];
            end
            else //jika tidak sama dengan nilai sebelumnya
            begin
              if (empId <> -1) then
              begin
                table[j*size + empId]:= table[j*size + i];
                table[j*size + i]:= 64;
                empId:= empId - 1;
              end;
              befId:= befId - 1;
              bef:= table[j*size + befId];
            end;
          if (table[j*size + i] = 64) and (empId = -1) then //table[i] kosong
              empId:= i;
        end;
      end;
    end;

    UP: begin
      for i:= 0 to size-1 do
      begin
        empId:= -1;
        befId:= -1;
        for j:= 0 to size-1 do
        begin
          if (table[j*size + i] <> 64) then//table[i] tidak kosong
            if (befId = -1) then //belum ada nilai sebelumnya
            begin
              befId:= j;
              bef:= table[j*size + i];
              if (empId <> -1) then //sebelumnya pernah kosong
              begin
                table[empId*size + i]:= bef;
                table[j*size + i]:= 64;
                befId:= empId;
                empId:= empId + 1;
              end;
            end
            else if(bef = table[j*size + i]) then //nilai sebelumnya sama dengan table[i]
            begin
              table[befId*size + i]:= table[befId*size + i] + 1;
              addScore(2**(table[befId*size + i] - 64));
              table[j*size + i]:= 64;
              count:= count - 1;
              befId:= -1;
              //bef:= table[befId*size + i];
            end
            else //jika tidak sama dengan nilai sebelumnya
            begin
              if (empId <> -1) then
              begin
                table[empId*size + i]:= table[j*size + i];
                table[j*size + i]:= 64;
                empId:= empId + 1;
              end;
              befId:= befId + 1;
              bef:= table[befId*size + i];
            end;
          if (table[j*size + i] = 64) and (empId = -1) then //table[i] kosong
              empId:= j;
        end;
      end;
    end;

    DOWN: begin
      for i:= 0 to size-1 do
      begin
        empId:= -1;
        befId:= -1;
        for j:= size-1 downto 0 do
        begin
          if (table[j*size + i] <> 64) then//table[i] tidak kosong
            if (befId = -1) then //belum ada nilai sebelumnya
            begin
              befId:= j;
              bef:= table[j*size + i];
              if (empId <> -1) then //sebelumnya pernah kosong
              begin
                table[empId*size + i]:= bef;
                table[j*size + i]:= 64;
                befId:= empId;
                empId:= empId - 1;
              end;
            end
            else if(bef = table[j*size + i]) then //nilai sebelumnya sama dengan table[i]
            begin
              table[befId*size + i]:= table[befId*size + i] + 1;
              addScore(2**(table[befId*size + i] - 64));
              table[j*size + i]:= 64;
              count:= count - 1;
              befId:= -1;
              //bef:= table[befId*size + i];
            end
            else //jika tidak sama dengan nilai sebelumnya
            begin
              if (empId <> -1) then
              begin
                table[empId*size + i]:= table[j*size + i];
                table[j*size + i]:= 64;
                empId:= empId - 1;
              end;
              befId:= befId - 1;
              bef:= table[befId*size + i];
            end;
          if (table[j*size + i] = 64) and (empId = -1) then //table[i] kosong
              empId:= j;
        end;
      end;
    end;

  end;
end;

function TBoard.getScore(): longint;
begin
  getScore:= score;
end;

procedure TBoard.setScore(const n: longInt);
begin
  score:= n;
end;

procedure TBoard.addScore(const n: longInt);
begin
  score:= score + n;
end;

function TBoard.getCount(): byte;
begin
  getCount:= count;
end;

procedure TBoard.copyTo(var arr: arrayByte);
var
  i: byte;
begin
  if(length(arr) <> len) then
    setLength(arr, len);
  for i:= 0 to len - 1 do
    arr[i]:= table[i];
end;

function TBoard.noMoveLeft(): boolean;
var
  i, j: byte;
  prev, prevY: byte;
  noMove: boolean;
begin
  noMove:= (count = len);
  if noMove then
  begin
    j:= 0;
    while noMove and (j < size) do
    begin
      i:= 0;
      while noMove and (i < size-1) do
      begin
        prev:= table[j*size + i];
        i:= i + 1;
        if (table[j*size + i] = prev) then
          noMove:= false;
      end;
      j:= j + 1;
    end;
  end;
  if noMove then
  begin
    i:= 0;
    while noMove and (i < size) do
    begin
      j:= 0;
      while noMove and (j < size-1) do
      begin
        prev:= table[j*size + i];
        j:= j + 1;
        if (table[j*size + i] = prev) then
          noMove:= false;
      end;
      inc(i);
    end;
  end;
  noMoveLeft:= noMove;
end;

{ TConsole }

constructor TConsole.create(const i0, j0, i1, j1: integer; const bor,
  pad: boolean);
begin
  x0:= i0;
  x1:= i1;
  y0:= j0;
  y1:= j1;
  SetConsoleWindow(i1 + 1, j1);
  border:= bor;
  padding:= pad;
  reset();
  if bor then
  begin
    cursoroff;
    drawBorder('#');
    cursoron;
    inc(x0); inc(y0);
    dec(x1); dec(y1);
    window(x0,y0,x1,y1);
  end;
  if pad then
  begin
    inc(x0); dec(x1);
    window(x0,y0,x1,y1);
  end;
  width:= x1 - x0;
  height:= y1 - y0;
end;

procedure TConsole.SetConsoleWindow(NewWidth : integer;NewHeight : integer);
var
  Rect: TSmallRect;
  Coord: TCoord;
begin { SetConsoleWindow }
  Coord.X := NewWidth;
  Coord.y := NewHeight;
  SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), Coord);
  Rect.Left := 0;   //  must be zero
  Rect.Top := 0;
  Rect.Right := Coord.X - (Rect.Left + 1);
  Rect.Bottom := Coord.y - (Rect.Top + 1);
  SetConsoleWindowInfo(GetStdHandle(STD_OUTPUT_HANDLE), True, Rect);
end; { SetConsoleWindow }

procedure TConsole.reset();
begin
  clrscr;
end;

procedure TConsole.drawBorder(const symbol: char);
var
  j: integer;
  buff: string;
begin
  buff:= '';
  for j:= x0 to x1 do
    buff:= buff + symbol;

  for j:= y0 to y1 do
  begin
    gotoXY(x0, j);
    if j in [y0, y1] then
      write(buff)
    else begin
      write(symbol);
      gotoXY(x1, j);
      write(symbol);
    end;
  end;
  gotoxy(x1, y1);
end;

procedure TConsole.writeNumRight(const num: longint; x, y: integer);
var
  len: integer;
  i: byte;
begin
  len:= 1;
  while (num div round(intpower(10,len)) <> 0) do
    inc(len);
  gotoXY(x - len, y);
  write(num);
end;

procedure TConsole.WriteAlignMiddle(const str: string; x, y: integer);
begin
  gotoXY(x - length(str) div 2, y);
  write(str);
end;

procedure TConsole.writeXY(const str: string; x, y: integer);
begin
  gotoXY(x, y);
  write(str);
end;

procedure TConsole.writeXY(const num: longInt; x, y: integer);
begin
  gotoXY(x,y);
  write(num);
end;

procedure TConsole.fillBlank(const x2, y2, x3, y3: integer);
var
  i: integer;
  buff: string = '';
begin
  for i:= x2 to x3 do
    buff:= buff + ' ';
  for i:= y2 to y3 do
    writeXY(buff,x2,i);
end;

function toStr(const arrCh: arrayStcChar; const len: byte): string;
var
  buff: string;
  i: integer;
begin
  buff:= '';
  i:= 0;
  while i < len do begin
    buff:= buff + arrCh[i];
    inc(i);
  end;
  toStr:= buff;
end;

function subStr(const str: string; start, len: integer): string;
var
  buff: string;
  i: integer;
begin
  buff:= '';
  if (start + len - 1 > length(str)) then
    len:= length(str) - start + 1;
  for i:= 0 to len-1 do
    buff:= buff + str[i + start];
  subStr:= buff;
end;

{ Main Function }

Procedure Setup();
begin
  Randomize;
  console:= TConsole.create(1,1,81,30, true, true);
end;

Procedure Routine();
var
  main: TMainSystem;
  //input: TInputBox;
begin
  main:= TMainSystem.create;
  main.routine();
  freeAndNil(main);
end;

Begin
  Setup;
  Routine;
  freeAndNil(console);
End.

