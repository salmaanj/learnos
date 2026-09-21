package com.learnos.auth.security;

import com.learnos.config.CustomUserDetailsService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final CustomUserDetailsService userDetailsService;


    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {

        String path = request.getRequestURI();

        return path.startsWith("/auth")
                || path.startsWith("/companies")
                || path.startsWith("/api/company-users")
                || request.getMethod().equals("OPTIONS");
    }


    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {


        String header =
                request.getHeader("Authorization");


        if(header == null || !header.startsWith("Bearer ")) {

            filterChain.doFilter(request,response);
            return;
        }


        String token =
                header.substring(7);


        try {

            String email =
                    jwtUtil.extractEmail(token);


            if(email != null &&
                    SecurityContextHolder
                            .getContext()
                            .getAuthentication() == null) {


                UserDetails userDetails =
                        userDetailsService
                                .loadUserByUsername(email);


                if(jwtUtil.isTokenValid(token,email)) {


                    UsernamePasswordAuthenticationToken auth =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails,
                                    null,
                                    userDetails.getAuthorities()
                            );


                    auth.setDetails(
                            new WebAuthenticationDetailsSource()
                                    .buildDetails(request)
                    );


                    SecurityContextHolder
                            .getContext()
                            .setAuthentication(auth);
                }
            }


        } catch(Exception e) {

            System.out.println(
                    "JWT ERROR : " + e.getMessage()
            );
        }


        filterChain.doFilter(request,response);
    }
}