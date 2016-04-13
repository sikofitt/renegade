<?php
$pashash = '$2y$12$isWcbuF/pkmWmlg0Fa3FoOH55uh/QgGK56RkskFytK421TZv.wVbK';
print 'Pas hash : ' . $pashash . PHP_EOL;
print 'php hash : ' . password_hash('password', PASSWORD_DEFAULT, ['cost' => 12]) . PHP_EOL;
var_dump(password_verify('password', $pashash));
var_dump(password_needs_rehash($pashash, PASSWORD_DEFAULT, ['cost' => 12]));
