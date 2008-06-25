/*  $Id$

    Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        wielemak@science.uva.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 1985-2007, University of Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(http_stress_server,
	  [ server/1,			% +Port
	    profile/0
	  ]).
:- load_files([ library('http/thread_httpd'),
		library('http/html_write'),
		library('http/http_session'),
		library('http/http_dispatch'),
		library('http/http_error')
	      ],
	      [ silent(true)
	      ]).

/** <module> Sample HTTP server to run some stress tests

*/

%%	server(+Port) is det.
%
%	Start the server at Port.

server(Port) :-
	server(Port,
	       [ workers(1)
	       ]).

server(Port, Options) :-
	http_server(http_dispatch,
		    [ port(Port),
		      timeout(20)
		    | Options
		    ]).

%%	profile
%
%	Run thread profiler on the one and only server.

profile :-
	findall(Id, http_current_worker(_, Id), Ids),
	(   Ids = [Id]
	->  tprofile(Id)
	;   Ids == []
	->  format(user_error, 'No HTTP server!~n', []),
	    fail
	;   format(user_error, 'Multiple HTPP workers: ~p~n', [Ids]),
	    fail
	).


		 /*******************************
		 *	     METHODS		*
		 *******************************/

:- http_handler('/ping', ping, []).

ping(_Request) :-
	format('Content-type: text/plain~n~n'),
	format('alife~n').