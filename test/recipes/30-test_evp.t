#! /usr/bin/env perl
# Copyright 2015-2025 The OpenSSL Project Authors. All Rights Reserved.
#
# Licensed under the Apache License 2.0 (the "License").  You may not use
# this file except in compliance with the License.  You can obtain a copy
# in the file LICENSE in the source distribution or at
# https://www.openssl.org/source/license.html


use strict;
use warnings;

use OpenSSL::Test qw(:DEFAULT data_file bldtop_dir srctop_file srctop_dir bldtop_file);
use OpenSSL::Test::Utils;

BEGIN {
    setup("test_evp");
}

use lib srctop_dir('Configurations');
use lib bldtop_dir('.');

my $no_fips = disabled('fips') || ($ENV{NO_FIPS} // 0);
my $no_legacy = disabled('legacy') || ($ENV{NO_LEGACY} // 0);
my $no_des = disabled("des");
my $no_dh = disabled("dh");
my $no_slh_dsa = disabled("slh-dsa");
my $no_dsa = disabled("dsa");
my $no_ec = disabled("ec");
my $no_ecx = disabled("ecx");
my $no_ec2m = disabled("ec2m");
my $no_sm2 = disabled("sm2");
my $no_siv = disabled("siv");
my $no_argon2 = disabled("argon2");
my $no_ml_dsa = disabled("ml-dsa");
my $no_ml_kem = disabled("ml-kem");
my $no_lms = disabled("lms");

# Default config depends on if the legacy module is built or not
my $defaultcnf = $no_legacy ? 'default.cnf' : 'default-and-legacy.cnf';

my @configs = ( $defaultcnf );
# Only add the FIPS config if the FIPS module has been built
push @configs, 'fips-and-base.cnf' unless $no_fips;

# A list of tests that run with both the default and fips provider.
my @files = qw(
                evpciph_aes_ccm_cavs.txt
                evpciph_aes_common.txt
                evpciph_aes_cts.txt
                evpciph_aes_wrap.txt
                evpciph_aes_stitched.txt
                evpciph_des3_common.txt
                evpkdf_hkdf.txt
                evpkdf_kbkdf_counter.txt
                evpkdf_kbkdf_kmac.txt
                evpkdf_pbkdf1.txt
                evpkdf_pbkdf2.txt
                evpkdf_ss.txt
                evpkdf_ssh.txt
                evpkdf_tls12_prf.txt
                evpkdf_tls13_kdf.txt
                evpkdf_x942.txt
                evpkdf_x963.txt
                evpmac_common.txt
                evpmd_sha.txt
                evppbe_pbkdf2.txt
                evppkey_kdf_hkdf.txt
                evppkey_rsa.txt
                evppkey_rsa_common.txt
                evppkey_rsa_kem.txt
                evppkey_rsa_sigalg.txt
                evprand.txt
              );
push @files, qw(
                evppkey_ffdhe.txt
                evppkey_dh.txt
               ) unless $no_dh;
push @files, qw(
                evpkdf_x942_des.txt
                evpmac_cmac_des.txt
               ) unless $no_des;
push @files, qw(
                evppkey_slh_dsa_siggen.txt
                evppkey_slh_dsa_sigver.txt
               ) unless $no_slh_dsa;
push @files, qw(
                evppkey_dsa.txt
                evppkey_dsa_sigalg.txt
               ) unless $no_dsa;
push @files, qw(
                evppkey_ecx.txt
                evppkey_ecx_sigalg.txt
                evppkey_mismatch_ecx.txt
               ) unless $no_ecx;
push @files, qw(
                evppkey_ecc.txt
                evppkey_ecdh.txt
                evppkey_ecdsa.txt
                evppkey_ecdsa_sigalg.txt
                evppkey_kas.txt
                evppkey_mismatch.txt
               ) unless $no_ec;
push @files, qw(
                evppkey_ml_dsa_keygen.txt
                evppkey_ml_dsa_siggen.txt
                evppkey_ml_dsa_sigver.txt
                evppkey_ml_dsa_44_wycheproof_sign.txt
                evppkey_ml_dsa_44_wycheproof_verify.txt
                evppkey_ml_dsa_65_wycheproof_sign.txt
                evppkey_ml_dsa_65_wycheproof_verify.txt
                evppkey_ml_dsa_87_wycheproof_sign.txt
                evppkey_ml_dsa_87_wycheproof_verify.txt
               ) unless $no_ml_dsa;
push @files, qw(
                evppkey_ml_kem_512_keygen.txt
                evppkey_ml_kem_512_encap.txt
                evppkey_ml_kem_512_decap.txt
                evppkey_ml_kem_768_keygen.txt
                evppkey_ml_kem_768_encap.txt
                evppkey_ml_kem_768_decap.txt
                evppkey_ml_kem_1024_keygen.txt
                evppkey_ml_kem_1024_encap.txt
                evppkey_ml_kem_1024_decap.txt
                evppkey_ml_kem_keygen.txt
                evppkey_ml_kem_encap_decap.txt
               ) unless $no_ml_kem;
push @files, qw(
                evppkey_lms_sigver.txt
               ) unless $no_lms;

# A list of tests that only run with the default provider
# (i.e. The algorithms are not present in the fips provider)
my @defltfiles = qw(
                     evpciph_aes_ocb.txt
                     evpciph_aria.txt 
                     evpciph_bf.txt
                     evpciph_camellia.txt
                     evpciph_camellia_cts.txt
                     evpciph_cast5.txt
                     evpciph_chacha.txt
                     evpciph_des.txt
                     evpciph_idea.txt
                     evpciph_rc2.txt
                     evpciph_rc4.txt
                     evpciph_rc4_stitched.txt
                     evpciph_rc5.txt
                     evpciph_seed.txt
                     evpciph_sm4.txt
                     evpencod.txt
                     evpkdf_krb5.txt
                     evpkdf_scrypt.txt
                     evpkdf_tls11_prf.txt
                     evpkdf_hmac_drbg.txt
                     evpmac_blake.txt
                     evpmac_poly1305.txt
                     evpmac_siphash.txt
                     evpmac_sm3.txt
                     evpmd_blake.txt
                     evpmd_md.txt
                     evpmd_mdc2.txt
                     evpmd_ripemd.txt
                     evpmd_sm3.txt
                     evpmd_whirlpool.txt
                     evppbe_scrypt.txt
                     evppbe_pkcs12.txt
                     evppkey_kdf_scrypt.txt
                     evppkey_kdf_tls1_prf.txt
                    );
push @defltfiles, qw(evppkey_brainpool.txt) unless $no_ec;
push @defltfiles, qw(evppkey_ecdsa_rfc6979.txt) unless $no_ec;
push @defltfiles, qw(evppkey_ecx_kem.txt) unless $no_ecx;
push @defltfiles, qw(evppkey_dsa_rfc6979.txt) unless $no_dsa;
push @defltfiles, qw(evppkey_sm2.txt) unless $no_sm2;
push @defltfiles, qw(evpciph_aes_gcm_siv.txt) unless $no_siv;
push @defltfiles, qw(evpciph_aes_siv.txt) unless $no_siv;
push @defltfiles, qw(evpkdf_argon2.txt) unless $no_argon2;

plan tests =>
    + (scalar(@configs) * scalar(@files))
    + scalar(@defltfiles)
    + 3; # error output tests

foreach (@configs) {
    my $conf = srctop_file("test", $_);

    foreach my $f ( @files ) {
        ok(run(test(["evp_test",
                     "-config", $conf,
                     data_file("$f")])),
           "running evp_test -config $conf $f");
    }
}

my $conf = srctop_file("test", $defaultcnf);
foreach my $f ( @defltfiles ) {
    ok(run(test(["evp_test",
                 "-config", $conf,
                 data_file("$f")])),
       "running evp_test -config $conf $f");
}

# test_errors OPTIONS
#
# OPTIONS may include:
#
# key      => "filename"        # expected to be found in $SRCDIR/test/certs
# out      => "filename"        # file to write error strings to
# args     => [ ... extra openssl pkey args ... ]
# expected => regexps to match error lines against
sub test_errors { # actually tests diagnostics of OSSL_STORE
    my %opts = @_;
    my $infile = srctop_file('test', 'certs', $opts{key});
    my @args = ( qw(openssl pkey -in), $infile, @{$opts{args} // []} );
    my $res = !run(app([@args], stderr => $opts{out}));
    my $found = !exists $opts{expected};
    open(my $in, '<', $opts{out}) or die "Could not open file $opts{out}";
    while(my $errline = <$in>) {
        print $errline; # this may help debugging

        # output must not include ASN.1 parse errors
        $res &&= $errline !~ m/asn1 encoding/;
        # output must include what is expressed in $opts{$expected}
        $found = 1
            if exists $opts{expected} && $errline =~ m/$opts{expected}/;
    }
    close $in;
    # $tmpfile is kept to help with investigation in case of failure
    return $res && $found;
}

SKIP: {
    skip "DSA not disabled or ERR disabled", 2
        if !disabled("dsa") || disabled("err");

    ok(test_errors(key => 'server-dsa-key.pem',
                   out => 'server-dsa-key.err'),
       "expected error loading unsupported dsa private key");
    ok(test_errors(key => 'server-dsa-pubkey.pem',
                   out => 'server-dsa-pubkey.err',
                   args => [ '-pubin' ],
                   expected => 'unsupported'),
       "expected error loading unsupported dsa public key");
}

SKIP: {
    skip "SM2 not disabled", 1 if !disabled("sm2");

    ok(test_errors(key => 'sm2.key', out => 'sm2.err'),
       "expected error loading unsupported sm2 private key");
}
