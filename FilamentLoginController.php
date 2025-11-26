<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class FilamentLoginController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // Get user from database
        $user = User::where('email', $request->email)->first();

        // Check if user exists and password is correct
        if (!$user || !Hash::check($request->password, $user->password)) {
            return redirect()
                ->back()
                ->withErrors(['email' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة'])
                ->withInput($request->except('password'));
        }

        // Check if user is admin
        if (!$user->is_admin) {
            return redirect()
                ->back()
                ->withErrors(['email' => 'هذا الحساب لا يملك صلاحيات الإدارة'])
                ->withInput($request->except('password'));
        }

        // Login the user
        Auth::login($user, $request->boolean('remember'));
        $request->session()->regenerate();

        // Redirect to Filament admin panel
        return redirect('/admin/analytics');
    }
}
