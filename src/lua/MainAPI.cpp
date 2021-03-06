/*
 * Copyright (C) 2006-2012 Christopho, Solarus - http://www.solarus-games.org
 *
 * Solarus is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Solarus is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include "lua/LuaContext.h"
#include "lowlevel/Geometry.h"
#include "MainLoop.h"
#include "Timer.h"
#include "CustomScreen.h"
#include <lua.hpp>
#include <sstream>
#include <cmath>

const std::string Script::main_module_name = "sol.main";

/**
 * @brief Initializes the main features provided to Lua.
 */
void Script::register_main_module() {

  static const luaL_Reg functions[] = {
      { "include", main_api_include },
      { "reset", main_api_reset },
      { "exit", main_api_exit },
      { "start_screen", main_api_start_screen },
      { "get_distance", main_api_get_distance },
      { "get_angle", main_api_get_angle },
      { NULL, NULL }
  };
  register_functions(main_module_name, functions);
}

/**
 * @brief Pushes the sol.main table onto the stack.
 * @param l A Lua state.
 */
void LuaContext::push_main(lua_State* l) {

                                  // ...
  lua_getglobal(l, "sol");
                                  // ... sol
  lua_getfield(l, -1, "main");
                                  // ... sol main
  lua_remove(l, -2);
                                  // ... main
}

/**
 * @brief Implementation of \ref lua_api_main_include.
 * @param l the Lua context that is calling this function
 * @return number of values to return to Lua
 */
int Script::main_api_include(lua_State *l) {

  Script& script = get_script(l);
  const std::string& file_name = luaL_checkstring(l, 1);

  script.load(file_name);

  return 0;
}

/**
 * @brief Implementation of \ref lua_api_main_reset.
 * @param l the Lua context that is calling this function
 * @return number of values to return to Lua
 */
int Script::main_api_reset(lua_State* l) {

  Script& script = get_script(l);

  script.get_main_loop().set_resetting();

  return 0;
}

/**
 * @brief Implementation of \ref lua_api_main_exit.
 * @param l the Lua context that is calling this function
 * @return number of values to return to Lua
 */
int Script::main_api_exit(lua_State* l) {

  Script& script = get_script(l);

  script.get_main_loop().set_exiting();

  return 0;
}

/**
 * @brief Implementation of \ref lua_api_main_start_screen.
 * @param l the Lua context that is calling this function
 * @return number of values to return to Lua
 */
int Script::main_api_start_screen(lua_State* l) {

  Script& script = get_script(l);
  luaL_checktype(l, 1, LUA_TTABLE);

  // Store the menu object.
  int menu_ref = script.create_ref();

  MainLoop& main_loop = script.get_main_loop();
  main_loop.set_next_screen(new CustomScreen(main_loop, menu_ref));

  return 0;
}

/**
 * @brief Implementation of \ref lua_api_main_get_distance.
 * @param l the Lua context that is calling this function
 * @return number of values to return to Lua
 */
int Script::main_api_get_distance(lua_State *l) {

  int x1 = luaL_checkinteger(l, 1);
  int y1 = luaL_checkinteger(l, 2);
  int x2 = luaL_checkinteger(l, 3);
  int y2 = luaL_checkinteger(l, 4);

  int distance = (int) Geometry::get_distance(x1, y1, x2, y2);
  lua_pushinteger(l, distance);

  return 1;
}

/**
 * @brief Implementation of \ref lua_api_main_get_angle.
 * @param l the Lua context that is calling this function
 * @return number of values to return to Lua
 */
int Script::main_api_get_angle(lua_State *l) {

  int x1 = luaL_checkinteger(l, 1);
  int y1 = luaL_checkinteger(l, 2);
  int x2 = luaL_checkinteger(l, 3);
  int y2 = luaL_checkinteger(l, 4);

  double angle = Geometry::get_angle(x1, y1, x2, y2);
  lua_pushnumber(l, angle);

  return 1;
}

/**
 * @brief Calls sol.main.on_update() if it exists.
 *
 * This function is called at each cycle by the main loop.
 */
void LuaContext::main_on_update() {

  push_main(l);
  on_update();
  lua_pop(l, 1);
}

/**
 * @brief Notifies Lua that an input event has just occurred.
 *
 * The appropriate callback in sol.main is triggered if it exists.
 *
 * @param event The input event to handle.
 */
void LuaContext::main_on_input(InputEvent& event) {

  push_main(l);
  on_input(event);
  lua_pop(l, 1);
}

/**
 * @brief Calls sol.main.on_started() if it exists.
 *
 * This function is called when the engine requests Lua to show an
 * initial screen, i.e. at the beginning of the program
 * or when the program is reset.
 */
void LuaContext::main_on_started() {

  push_main(l);
  enable_timers(l, -1);
  on_started();
  lua_pop(l, 1);
}

/**
 * @brief Calls sol.main.on_finished() if it exists.
 *
 * This function is called when the program is reset or stopped.
 */
void LuaContext::main_on_finished() {

  push_main(l);
  on_finished();
  disable_timers(l, -1);
  lua_pop(l, 1);
}

