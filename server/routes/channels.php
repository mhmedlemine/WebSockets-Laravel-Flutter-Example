<?php

use Illuminate\Support\Facades\Broadcast;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
|
| Here you may register all of the event broadcasting channels that your
| application supports. The given channel authorization callbacks are
| used to check if an authenticated user can listen to the channel.
|
*/

Broadcast::channel('App.User.{id}', function ($user, $id) {
    // $user is an authenticated user and $id is the requested access by authenticated user
    return (int) $user->id === (int) $id;
});

Broadcast::channel('presence.channel', function ($user) {
    return true;
});
